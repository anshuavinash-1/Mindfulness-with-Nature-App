# Mindfulness with Nature App

A Flutter application for mindfulness and nature connection, featuring mood tracking, favorite places, and daily reminders.

## Features

- **Mood Tracking**: Log your daily mood and stress levels with notes
- **Favorite Places**: Save and organize your favorite nature spots
- **User Authentication**: Firebase authentication with local fallback
- **Location Services**: Find places near your current location using Haversine distance calculations

## Getting Started

### Prerequisites

- Flutter SDK >=3.2.0 <4.0.0
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode for mobile development

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Testing

The project includes comprehensive unit tests for models and services.

### Running All Tests

```bash
flutter test
```

### Running Specific Tests

```bash
# Test models only
flutter test test/models/

# Test services only
flutter test test/services/

# Test a specific file
flutter test test/services/mood_service_test.dart
```

### Test Coverage

- **Model Tests** (`test/models/`):
  - `user_model_test.dart`: User and UserPreferences models (21 tests)
  
- **Service Tests** (`test/services/`):
  - `mood_service_test.dart`: MoodService with SharedPreferences (10 tests)
  - `place_service_test.dart`: PlacesService with location calculations (11 tests)

Total: **42 passing tests**

### Writing Tests

Tests use:
- `flutter_test` for core testing framework
- `mockito` for mocking dependencies
- `shared_preferences` mock for local storage testing

Example:
```dart
test('should add a new mood entry', () async {
  final entry = MoodEntry(
    timestamp: DateTime.now(),
    moodLevel: 5,
    stressLevel: 2,
    notes: 'Feeling great',
    userId: 'test-user',
  );
  
  await moodService.addEntry(entry);
  expect(moodService.entries.length, equals(1));
});
```

## CI/CD

Tests run automatically on:
- Push to `main` branch
- Pull requests to `main`

See `.github/workflows/flutter-test.yaml` for CI configuration.

## Architecture

- **State Management**: Provider pattern
- **Local Storage**: SharedPreferences for mood entries and favorite places
- **Authentication**: Firebase Auth with graceful degradation
- **Location**: Haversine formula for distance calculations

## Project Structure

```
lib/
├── models/          # Data models (User, MoodEntry, FavoritePlace)
├── services/        # Business logic (Auth, Mood, Places, Notifications)
└── pages/           # UI screens

test/
├── models/          # Model unit tests
└── services/        # Service unit tests
```
