import Darwin
import Foundation

final class LaunchAgentService {
    private let fileManager = FileManager.default
    private let label = "com.earthlens.wallpaper"

    func status(fallbackState: PersistedState) -> LaunchAgentStatus {
        guard
            fileManager.fileExists(atPath: AppPaths.launchAgentPlist.path),
            let plist = NSDictionary(contentsOf: AppPaths.launchAgentPlist) as? [String: Any]
        else {
            return LaunchAgentStatus(
                enabled: fallbackState.rotationEnabled,
                interval: fallbackState.rotationInterval,
                executablePath: fallbackState.lastKnownExecutablePath
            )
        }

        let interval = RotationInterval(rawValue: plist["StartInterval"] as? Int ?? fallbackState.rotationInterval.rawValue)
            ?? fallbackState.rotationInterval
        let executablePath = (plist["ProgramArguments"] as? [String])?.first

        return LaunchAgentStatus(
            enabled: true,
            interval: interval,
            executablePath: executablePath
        )
    }

    var hasCurrentConfiguration: Bool {
        fileManager.fileExists(atPath: AppPaths.launchAgentPlist.path)
    }

    var hasLegacyConfiguration: Bool {
        fileManager.fileExists(atPath: AppPaths.legacyLaunchAgentPlist.path)
    }

    func install(interval: RotationInterval, executablePath: String, runAtLoad: Bool = false) throws {
        try AppPaths.ensureDirectories()
        try removeLegacyConfigurationIfNeeded()

        let plist: [String: Any] = [
            "Label": label,
            "LimitLoadToSessionType": "Aqua",
            "ProgramArguments": [executablePath, "--rotate"],
            "RunAtLoad": runAtLoad,
            "StartInterval": interval.rawValue,
            "StandardOutPath": AppPaths.logFile.path,
            "StandardErrorPath": AppPaths.logFile.path,
            "WorkingDirectory": AppPaths.supportDirectory.path
        ]

        let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try data.write(to: AppPaths.launchAgentPlist, options: .atomic)

        _ = try? runLaunchctl(["bootout", launchDomain, AppPaths.launchAgentPlist.path])

        do {
            _ = try runLaunchctl(["bootstrap", launchDomain, AppPaths.launchAgentPlist.path])
        } catch {
            _ = try runLaunchctl(["load", AppPaths.launchAgentPlist.path])
        }
    }

    func uninstall() throws {
        if fileManager.fileExists(atPath: AppPaths.launchAgentPlist.path) {
            _ = try? runLaunchctl(["bootout", launchDomain, AppPaths.launchAgentPlist.path])
            _ = try? runLaunchctl(["unload", AppPaths.launchAgentPlist.path])
            try fileManager.removeItem(at: AppPaths.launchAgentPlist)
        }

        try removeLegacyConfigurationIfNeeded()
    }

    private var launchDomain: String {
        "gui/\(getuid())"
    }

    private func removeLegacyConfigurationIfNeeded() throws {
        guard fileManager.fileExists(atPath: AppPaths.legacyLaunchAgentPlist.path) else {
            return
        }

        _ = try? runLaunchctl(["bootout", launchDomain, AppPaths.legacyLaunchAgentPlist.path])
        _ = try? runLaunchctl(["unload", AppPaths.legacyLaunchAgentPlist.path])
        try fileManager.removeItem(at: AppPaths.legacyLaunchAgentPlist)
    }

    @discardableResult
    private func runLaunchctl(_ arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = arguments

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = outputPipe

        try process.run()
        process.waitUntilExit()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard process.terminationStatus == 0 else {
            throw EarthLensError.launchAgentFailed(output.isEmpty ? arguments.joined(separator: " ") : output)
        }

        return output
    }
}
