# Activity 14 - Firebase Cloud Messaging

## Overview
This Flutter app demonstrates Firebase Cloud Messaging integration across all app lifecycle states.

## Features
- Firebase initialization
- Notification permission request
- FCM token display
- Foreground message handling with `onMessage`
- Background tap handling with `onMessageOpenedApp`
- Terminated app handling with `getInitialMessage()`
- UI updates from notification/data payloads
- Safe defaults for missing payload fields

## Packages Used
- firebase_core
- firebase_messaging

## How to Run
1. Run `flutter pub get`
2. Run `flutterfire configure`
3. Launch with `flutter run`

## Test Scenarios
- Foreground message
- Background notification tap
- Terminated launch from notification
- Valid payload test
- Incomplete payload safety test

## Evidence Collected
- Token screenshot
- Foreground screenshot
- Background screenshot
- Terminated screenshot
- Console logs showing handler execution

## Reflection Summary
This activity showed how FCM behaves differently depending on whether the app is active, backgrounded, or terminated. The project used a single FCM service and safe payload mapping to keep the code organized and prevent crashes from missing data.
