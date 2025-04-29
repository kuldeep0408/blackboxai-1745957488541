# Khojo App

## Overview
Khojo App is a cross-platform mobile application built with Flutter to help people report and find lost items in their local area. It includes user registration, lost/found item posting, location-based notifications, map view, in-app messaging, and a web-based admin panel built with React and Tailwind CSS.

## Tech Stack
- Mobile App: Flutter
- Backend: Firebase (Authentication, Firestore, Cloud Functions, Cloud Messaging)
- Admin Panel: React with Tailwind CSS
- Maps: Google Maps API
- Notifications: Firebase Cloud Messaging (FCM)

## Project Structure
- `mobile_app/`: Flutter mobile app source code
- `admin_panel/`: React admin panel source code

## Setup Instructions

### Mobile App
1. Install Flutter SDK: https://flutter.dev/docs/get-started/install
2. Navigate to `mobile_app` directory.
3. Run `flutter pub get` to install dependencies.
4. Configure Firebase for Android and iOS as per Firebase docs.
5. Run the app on emulator or device: `flutter run`

### Admin Panel
1. Navigate to `admin_panel` directory.
2. Run `npm install` to install dependencies.
3. Run `npm start` to start the development server.
4. Configure Firebase Authentication and Firestore in the admin panel as needed.

## Deployment
- Build Android APK: `flutter build apk` in `mobile_app`
- Build iOS IPA: `flutter build ios` in `mobile_app` (requires macOS)
- Build Admin Panel: `npm run build` in `admin_panel`

## Database Schema
- Users collection: user profiles with location
- Posts collection: lost/found items with details and location
- Chats collection: messages and chat status
- Reports collection: spam/fake post reports

## Notes
- Google Maps API key required for map features.
- Firebase project setup required for authentication, database, and messaging.
