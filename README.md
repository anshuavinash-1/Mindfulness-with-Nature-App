# 🌿 Mindfulness with Nature App
Mindfulness with Nature App is a mobile application that combines guided mindfulness exercises with nature's restorative power through audio/video sessions, progress tracking, and mood reflection tools.

## The Problem

Millions struggle with daily stress and burnout. Many want to meditate but don't know where to start or struggle to stay consistent. Traditional apps feel cold and disconnected from the natural world that calms us.

**Our solution:** A calm, nature-inspired app that makes mindfulness practice feel like a walk in the woods — not another task on your to-do list.

## ✨ Key Features
* **Guided Meditation:** Timed sessions with nature sounds (forest, ocean, meadow)
* **Mood Tracking:**  Log your emotions and see patterns over time 
* **Progress Dashboard:** Track meditation streaks and session history
* **Favorite Places:** Save and share peaceful real-world locations
* **Gentle Reminders:** Daily prompts to check in with yourself 

## 🚀 Try It Yourself

### Web Version: https://mindfulness-with-nature-2025.web.app/
### Mobile (iOS & Android)
📱 Download coming soon!!

### Source Code
[GitHub Repository](https://github.com/anshuavinash-1/Mindfulness-with-Nature-App)

### Requirements
- **Web:** Any modern browser (Chrome, Safari, Firefox)
- **Mobile:** iOS 13+ or Android 8+
- No account needed to try — sign up as a guest

# Team:
* **Anshu Avinash** | UI/UX & Authentication | [@anshuavinash-1](
* **Mitchell Bourdukofsky** | Backend & Firebase | [@mitch311111]
*  **Ryan Kelly** | Testing & QA | [@ryankelly85556]


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

