# Masarak

Masarak is an Arabic-first employment application built with Flutter. It helps job seekers discover suitable opportunities, apply for jobs, track applications and interviews, and manage their professional profiles from one place.

## Project Overview

Masarak provides an integrated digital experience for job seekers, starting with professional profile creation and job discovery, then continuing through application tracking, interview management, and real-time notifications.

## Key Features

### Authentication

- User registration.
- Login and logout.
- Email verification.
- Password recovery.
- Password reset and change.
- Local session persistence.

### Professional Profile

- Personal information management.
- Professional skills management.
- CV upload.
- Profile photo upload.
- Profile viewing and editing.
- Account settings management.

### Job Discovery

- Browse available jobs.
- Search for job opportunities.
- View detailed job information.
- Access company information.
- Review required skills and qualifications.
- Apply directly through the application.

### Job Applications

- View all submitted applications.
- Track the status of each application.
- Filter applications by status.
- Withdraw an application after confirmation.
- Clear loading, success, empty, and error states.

### Interviews

- View scheduled interviews.
- Access interview dates and times.
- View interview locations or meeting types.
- Track interview status.
- Review interviewer information.

### Notifications

- Real-time notifications using Firebase Cloud Messaging.
- In-app notification center.
- Background notification handling.
- Notification-topic subscriptions.
- General and user-specific notification support.

### User Experience

- Arabic and English support.
- Arabic as the default language.
- Right-to-left interface support.
- Smooth animations and page transitions.
- Skeleton loading interfaces.
- Animated empty states.
- Clear success and error feedback.
- Modern, responsive user interface.

## Tech Stack

- Flutter
- Dart
- Provider
- MVVM Architecture
- Dio
- HTTP
- GoRouter
- Firebase Core
- Firebase Cloud Messaging
- Flutter Local Notifications
- Shared Preferences
- File Picker
- Image Picker
- Flutter Animate
- Animations
- Rive
- Skeletonizer
- Google Fonts
- Cairo Font
- URL Launcher
- Flutter Native Splash

## Project Architecture

The project follows the MVVM pattern with clear separation between presentation, state management, data models, and external services:

```text
lib/
├── core/
├── model/
├── routing/
├── services/
├── theme/
├── utils/
├── view/
├── viewmodel/
├── widget/
└── main.dart
```

### Directory Responsibilities

- **Model:** Job, application, interview, notification, and user data models.
- **View:** Application screens and user interfaces.
- **ViewModel:** State management and interaction logic.
- **Services:** REST API communication, authentication, and notification services.
- **Routing:** Application routes and navigation.
- **Theme:** Colors, typography, shadows, and visual identity.
- **Widgets:** Reusable interface components.
- **Utils:** Local storage and shared helper utilities.

## User Journey

1. The user creates an account.
2. The email address is verified.
3. The user completes their professional profile, skills, photo, and CV.
4. Available jobs can be browsed or searched.
5. The user reviews a job and submits an application.
6. The application status is tracked from the applications screen.
7. Notifications are received whenever an important update occurs.
8. Scheduled interviews are managed from the application.
9. Profile information and account settings can be updated at any time.

## Requirements

- Flutter SDK compatible with Dart 3.9 or later.
- Android Studio or Visual Studio Code.
- Android/iOS emulator or physical device.
- A configured Firebase project.
- An accessible REST API backend.
- Notification permissions configured for the target platform.

## Firebase Configuration

Firebase configuration files are required to enable push notifications.

### Android

Place the following file inside `android/app`:

```text
google-services.json
```

### iOS

Place the following file inside `ios/Runner`:

```text
GoogleService-Info.plist
```

Firebase Cloud Messaging must also be enabled, and notification permissions must be configured for each target platform.

## Getting Started

```bash
git clone https://github.com/Saeed-Qatan/Masarak.git
cd Masarak
flutter pub get
flutter run
```

## Code Quality and Testing

```bash
flutter analyze
flutter test
```

## Important Notes

- Configure the REST API base URL for the development or production environment.
- Ensure that the backend server is running before testing connected features.
- Never commit API keys, private credentials, or other secrets.
- Configure Firebase separately for every target platform.
- Some application features require a working backend connection.

## Developer

**Saeed Qatan**

[GitHub Profile](https://github.com/Saeed-Qatan)