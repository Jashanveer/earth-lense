import AppKit
import SwiftUI

enum LaunchMode {
    case interactive
    case backgroundRotate

    static var current: LaunchMode {
        ProcessInfo.processInfo.arguments.contains("--rotate") ? .backgroundRotate : .interactive
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard LaunchMode.current == .backgroundRotate else { return }

        NSApp.setActivationPolicy(.prohibited)

        Task.detached {
            let service = EarthLensService()

            do {
                try await service.rotateFromBackground()
            } catch {
                await service.appendLog("Fatal background error: \(error.localizedDescription)")
            }

            await MainActor.run {
                NSApp.terminate(nil)
            }
        }
    }
}

@main
struct EarthLensApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    private let launchMode = LaunchMode.current

    init() {
        try? AppPaths.ensureDirectories()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if launchMode == .interactive {
                    ContentView()
                        .environmentObject(model)
                        .task {
                            await model.handleAppLaunch()
                        }
                } else {
                    Color.clear
                        .frame(width: 1, height: 1)
                }
            }
        }
        .defaultSize(width: 1_180, height: 780)
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
