# EarthLens

A native macOS app that sets stunning Google Earth View satellite images as your desktop wallpaper. Built with SwiftUI and the macOS 26 Liquid Glass design system.

EarthLens rotates through 2,500+ satellite images from around the world, with local caching, no-repeat history, and automatic background rotation via LaunchAgent.

## Download

Download the latest DMG from [Releases](https://github.com/Jashanveer/earth-lense/releases).

## Installation

1. Download `EarthLens.dmg` from the latest release.
2. Open the DMG and drag **EarthLens.app** into the **Applications** folder.
3. Launch EarthLens from your Applications folder.
4. If macOS shows a security prompt ("app downloaded from the internet"), go to **System Settings > Privacy & Security** and click **Open Anyway**.

## First-Time Setup

1. Open **EarthLens** from `/Applications`.
2. Click **Set Up Automatically** on the setup card.
3. If macOS asks for permission to control **System Events** or update the desktop picture, click **OK** or **Allow**.
4. EarthLens installs a user LaunchAgent so wallpaper rotation continues automatically after login.
5. To turn background rotation off later, open EarthLens and disable **Auto-Rotate**.

## Features

- **One-click wallpaper change** — Browse through satellite imagery with Previous/Next buttons.
- **Auto-rotate** — Configurable interval (30 min, 1 hr, 2 hr, 6 hr, 12 hr) for automatic wallpaper rotation in the background.
- **No repeats** — Tracks history so you never see the same image twice across 2,500+ images.
- **Lightweight** — Only one image is stored at a time. Previous images are cleaned up automatically.
- **Native macOS design** — Built with SwiftUI and Liquid Glass for a look that matches macOS 26.
- **Works on all Spaces** — Wallpaper is applied across all desktops and Spaces.

## Requirements

- macOS 26 (Tahoe) or later

## Building from Source

1. Make sure Xcode is installed and selected:

   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   ```

2. Open the project:

   ```bash
   open EarthLens.xcodeproj
   ```

3. Build and run in Xcode (Cmd+R), or build from the command line:

   ```bash
   xcodebuild -project EarthLens.xcodeproj -scheme EarthLens -configuration Release build
   ```

## How It Works

- **Image catalog**: Fetched from the [limhenry/earthview](https://github.com/limhenry/earthview) repository and cached locally. Refreshed automatically if older than 7 days.
- **Wallpaper setting**: Uses `osascript` (System Events) to set wallpaper on all desktops/Spaces, with `desktoppr` as a fallback.
- **Auto-rotate**: Backed by a user LaunchAgent at `~/Library/LaunchAgents/com.earthlens.wallpaper.plist`.
- **Data storage**: Runtime state is stored in `~/Library/Application Support/EarthLens/`.

## Project Structure

```
EarthLens/
  EarthLens/
    EarthLensApp.swift        # App entry point and lifecycle
    AppModel.swift            # Main view model
    Models/
      AppState.swift          # State types and rotation intervals
    Services/
      AppPaths.swift          # File path management
      EarthLensService.swift  # Image fetching and wallpaper setting
      LaunchAgentService.swift # LaunchAgent install/uninstall
    Views/
      ContentView.swift       # Main UI
      GlassPanel.swift        # Liquid Glass panel component
    Assets.xcassets           # App icons and assets
  Tools/
    GenerateAppIcon.swift     # App icon generation script
```

## License

MIT
