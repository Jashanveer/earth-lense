import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Already configured? Run as menu-bar agent only — close any window
        // SwiftUI auto-opened. The user can re-open via the menu bar item.
        guard hasCompletedSetup() else { return }
        for window in NSApp.windows where window.canBecomeMain {
            window.close()
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        true
    }

    private func hasCompletedSetup() -> Bool {
        guard
            let data = try? Data(contentsOf: AppPaths.stateFile),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return false
        }
        return (dict["setupCompleted"] as? Bool) ?? false
    }
}

@main
struct EarthLensApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    init() {
        Self.exitIfRedundantLaunch()
        try? AppPaths.ensureDirectories()
    }

    private static func exitIfRedundantLaunch() {
        // Older builds installed a LaunchAgent at ~/Library/LaunchAgents/com.earthlens.wallpaper.plist
        // that periodically execs `EarthLens --rotate`. The current architecture rotates from a timer
        // inside the long-lived menu-bar process, so any --rotate launch is redundant — bow out
        // before SwiftUI installs a second menu bar icon. The sandboxed App Store build can't
        // remove the orphaned plist; quitting fast is the next-best thing.
        if CommandLine.arguments.contains("--rotate") {
            exit(0)
        }

        let me = NSRunningApplication.current
        guard let bundleID = me.bundleIdentifier else { return }
        let siblings = NSRunningApplication.runningApplications(withBundleIdentifier: bundleID)
        if siblings.contains(where: { $0.processIdentifier < me.processIdentifier }) {
            exit(0)
        }
    }

    var body: some Scene {
        WindowGroup(id: "main") {
            ContentView()
                .environmentObject(model)
        }
        .defaultSize(width: 1_180, height: 780)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }

        MenuBarExtra("EarthLens", systemImage: "globe.americas.fill") {
            MenuBarMenu()
                .environmentObject(model)
        }
    }
}
