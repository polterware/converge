# Converge

Pomodoro on Mac. Real focus.

Converge is a native Pomodoro app for macOS built with SwiftUI. Focused on productivity and simplicity, it offers a complete Pomodoro timer with statistics, session history, notifications, and macOS menu bar integration.

## Features

### Pomodoro Timer

- Configurable timer with customizable duration for work, short break, and long break
- Automatic or manual mode for phase transitions
- Automatic long break after a configurable number of pomodoros (default: 4)
- Circular visual progress indicator
- Completed pomodoros counter

### Statistics and History

- Pomodoro counter per day, week, and month
- Productivity charts for the last 14 days
- Complete session history with date, time, and duration
- Statistics visible in menu bar and dedicated tab

### Interface and Experience

- Menu bar with always-visible timer
- Compact window to avoid interrupting workflow
- Themes: light, dark, or follow system
- Distinct colors for work and break phases
- Smooth transition animations

### Notifications

- Notifications at the end of each phase (work and break)
- Configurable sounds for each completion type
- Silent notifications option

### macOS Widget

- Desktop widget to track the timer without opening the app
- Automatic synchronization with the main app
- Real-time updates

### Automatic Updates

- Automatic update system via Sparkle
- Periodic check for new versions
- Simplified update installation

## Project Structure

```text
converge/
├── desktop/              # macOS Application (Swift/SwiftUI)
│   ├── converge/        # Application source code
│   ├── PomodoroWidget/  # Widget extension
│   └── scripts/         # Build and distribution scripts
├── web/                 # Landing page website (Next.js)
│   ├── app/             # Routes and API
│   └── components/      # React components
└── docs/                # Technical documentation
```

## Requirements

### For Users

- macOS 11.0 or higher
- Download the DMG file from the [download page](https://seu-dominio.com) or [GitHub Releases](https://github.com/rckbrcls/converge/releases)

### For Developers

- macOS 11.0 or higher
- Xcode 14.0 or higher
- Swift 5.7 or higher
- Node.js 18.0 or higher (for the website)
- pnpm (for website dependency management)

## Installation

### Application Installation

1. Download the DMG file from the [official page](https://seu-dominio.com) or [GitHub Releases](https://github.com/rckbrcls/converge/releases)
2. Open the downloaded DMG file
3. Drag the Converge app to the Applications folder
4. Run the app for the first time
5. If necessary, allow access in System Settings > Privacy & Security

**Note**: If the app is not signed/notarized, macOS may show security warnings. In this case, right-click on the app and select "Open".

## Usage

### Starting the Timer

1. Open the Converge app
2. Click "Start" to begin the work timer
3. The timer will count down from 25 minutes (or configured duration)
4. When finished, a notification will be displayed

### Menu Bar

The timer is always visible in the macOS menu bar, showing the remaining time. Click on the menu bar to:

- View remaining time
- Start, pause, or reset the timer
- Access quick statistics
- Open settings

### Settings

Access settings through the app menu (Cmd + ,) or the settings button in the interface:

- **Durations**: Configure work, short break, and long break duration
- **Pomodoros until long break**: Set how many pomodoros before a long break
- **Automatic mode**: Enable to automatically continue between phases
- **Notifications**: Configure sounds and alerts
- **Theme**: Choose between light, dark, or follow system
- **Updates**: Configure automatic update checking

### Keyboard Shortcuts

- `Cmd + ,`: Open settings
- `Cmd + Q`: Quit application

## Development

### Environment Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/rckbrcls/converge.git
   cd converge
   ```

1. Open the project in Xcode:

   ```bash
   open desktop/converge.xcodeproj
   ```

1. Configure App Group (for widget):
   - Select the `converge` target
   - Go to Signing & Capabilities
   - Add App Groups: `group.polterware.pomodoro.shared`
   - Repeat for the `PomodoroWidget` target

### Application Build

#### Development Build

1. Open the project in Xcode
2. Select the `converge` scheme
3. Press `Cmd + B` to build
4. Press `Cmd + R` to run

#### Release Build

Use the release script:

```bash
cd desktop
./scripts/release.sh patch  # or minor, major
```

This will:

- Increment version
- Build in Release mode
- Create DMG file
- Generate appcast.xml (if configured)

### Website Development

1. Enter the `web` directory:

   ```bash
   cd web
   ```

1. Install dependencies:

   ```bash
   pnpm install
   ```

1. Configure environment variables:

   ```bash
   cp .env.example .env.local
   # Edit .env.local and set NEXT_PUBLIC_DMG_DOWNLOAD_URL
   ```

1. Run the development server:

   ```bash
   pnpm dev
   ```

1. Access [http://localhost:3000](http://localhost:3000)

### Code Structure

#### Desktop Application

- `convergeApp.swift`: Application entry point and window configuration
- `PomodoroTimer.swift`: Main Pomodoro timer logic
- `PomodoroView.swift`: Main timer interface
- `PomodoroSettings.swift`: Settings management
- `StatisticsStore.swift`: Statistics storage and calculation
- `NotificationManager.swift`: Notification management
- `Services/`: Auxiliary services (WindowManager, UpdateManager, etc.)
- `Views/`: Reusable interface components
- `Models/`: Data models

#### Widget

- `PomodoroWidget.swift`: Main widget
- `PomodoroWidgetTimelineProvider.swift`: Timeline provider
- `PomodoroWidgetView.swift`: Widget views
- `WidgetDataManager.swift`: Shared data management

#### Website

- `app/page.tsx`: Main page (landing page)
- `app/api/releases/route.ts`: API to fetch releases
- `components/landing/`: Landing page components
- `components/ui/`: Reusable UI components

## Distribution

The project includes automated scripts to facilitate the distribution process:

- `scripts/release.sh`: Complete release script (version + build + DMG + appcast)
- `scripts/create-dmg.sh`: Create DMG file
- `scripts/increment-version.sh`: Increment version
- `scripts/generate-appcast.sh`: Generate appcast.xml for Sparkle
- `scripts/generate-keys.sh`: Generate EdDSA keys for signing
- `scripts/sign-dmg.sh`: Sign DMG with EdDSA
- `scripts/upload-to-github.sh`: Upload to GitHub Releases
- `scripts/upload-to-supabase.sh`: Upload to Supabase Storage

For more details on distribution and automatic updates, see the [distribution documentation](docs/DISTRIBUTION.md).

## Contributing

Contributions are welcome! To contribute:

1. Fork the project
2. Create a branch for your feature (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

### Code Standards

- Code in English (variables, methods, comments)
- Interface texts can be in Portuguese or English as needed
- Always create separate files for each component
- Keep code modularized
- Remove legacy code when making significant changes

## Documentation

Additional documentation is available in the `docs/` folder:

- [FEATURES.md](docs/FEATURES.md): Complete feature list
- [DISTRIBUTION.md](docs/DISTRIBUTION.md): Complete distribution guide
- [SETUP_DISTRIBUTION.md](docs/SETUP_DISTRIBUTION.md): Initial distribution setup
- [DMG.md](docs/DMG.md): How to create DMG files
- [RELEASES.md](docs/RELEASES.md): Release process
- [UPDATES.md](docs/UPDATES.md): Sparkle configuration for updates

## License

[Add license information here, if applicable]

## Contact

- GitHub: [https://github.com/rckbrcls/converge](https://github.com/rckbrcls/converge)
- Issues: [https://github.com/rckbrcls/converge/issues](https://github.com/rckbrcls/converge/issues)
