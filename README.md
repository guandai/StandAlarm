# StandAlarmX Watch App

StandAlarmX is a watchOS application designed to help users stay active by reminding them to stand up at regular intervals. The app features customizable reminder frequencies and a simple, user-friendly interface.

## Features

- **Customizable Reminder Frequency**: Choose from intervals of 5 seconds (for debugging), 30 minutes, 1 hour, or 2 hours.
- **Vibration Alerts**: Receive haptic feedback when it's time to stand.
- **Timer Status**: View the remaining time until the next reminder.
- **Pause and Resume**: Start or stop the timer as needed.

## Project Structure

```
StandAlarmX Watch App/
├── ContentView.swift          # Main UI for the app
├── StandAlarmXApp.swift        # App entry point
├── Assets.xcassets/           # App assets (icons, colors, etc.)
StandAlarmX Watch AppTests/
├── StandAlarmX_Watch_AppTests.swift  # Unit tests
StandAlarmX Watch AppUITests/
├── StandAlarmX_Watch_AppUITests.swift        # UI tests
├── StandAlarmX_Watch_AppUITestsLaunchTests.swift  # Launch tests
StandAlarmX.xcodeproj/
├── project.pbxproj            # Xcode project configuration
```

## Getting Started

### Prerequisites

- Xcode 14.0 or later
- watchOS 8.0 or later

### Running the App

1. Clone the repository to your local machine.
2. Open `StandAlarmX.xcodeproj` in Xcode.
3. Select the `StandAlarmX Watch App` target.
4. Build and run the app on a watchOS simulator or a connected Apple Watch.

## Usage

1. Launch the app on your Apple Watch.
2. Use the picker to select a reminder frequency.
3. Tap "Start" to begin the timer.
4. When the timer ends, you'll receive a vibration alert reminding you to stand.

## Testing

The project includes unit tests and UI tests:

- **Unit Tests**: Located in `StandAlarmX Watch AppTests/StandAlarmX_Watch_AppTests.swift`.
- **UI Tests**: Located in `StandAlarmX Watch AppUITests/`.

To run the tests, select the appropriate test target in Xcode and press `Cmd+U`.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

## Acknowledgments

- Developed by Zheng Dai.
- Inspired by the need to promote healthy habits through regular activity reminders.
