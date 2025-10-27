## Getting Started

### Prerequisites

- Flutter SDK (^3.11.0)
- Dart SDK
- Android Studio / Xcode (for mobile deployment)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/rishitaido/VehicleTrackerMAD.git
```

2. Navigate to the project directory:
```bash
cd VehicleTrackerMAD-1
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

## Project Structure

- `lib/`
  - `screens/` - All application screens
  - `models.dart` - Data models
  - `repos.dart` - Data repositories
  - `db.dart` - Database operations
  - `theme.dart` - Theme configuration
  - `utility/` - Helper functions and widgets

## Database Schema

The application uses SQLite for local data storage with the following main tables:

- `vehicles` - Stores vehicle information
- `maintenance_logs` - Tracks maintenance records
- `reminders` - Stores maintenance reminders

## Supported Platforms

- Android
- iOS
- Web
- Linux
- macOS
- Windows

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Team Members: Nick Johnson, Rishi Raj
- Flutter and Dart teams
- Contributors and testers

## Version

Current Version: 1.0.0

## Presentation 
A presentation detailing the project can be found [https://drive.google.com/file/d/1efwtCBIpMm5e5x4PpIIJSBIscR3OlMh_/view?usp=sharing]
