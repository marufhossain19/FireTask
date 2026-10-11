# 📱 FireTask — Firebase Task Manager

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/State_Management-Provider-blue?style=for-the-badge" alt="Provider" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
</p>

---

## 📥 Download Release APK

<p align="center">
  <a href="PASTE_YOUR_GOOGLE_DRIVE_APK_LINK_HERE">
    <img src="https://img.shields.io/badge/📥_Download_Release_APK-Google_Drive-34A853?style=for-the-badge&logo=googledrive&logoColor=white" alt="Download APK from Google Drive" />
  </a>
</p>

> 🔗 **Google Drive Direct Download Link**:  
> 👉 [**Click Here to Download FireTask APK from Google Drive**](PASTE_YOUR_GOOGLE_DRIVE_APK_LINK_HERE)  
> *(Replace `PASTE_YOUR_GOOGLE_DRIVE_APK_LINK_HERE` with your uploaded APK Drive sharing link)*

---

## 📖 Table of Contents
- [Project Overview](#-project-overview)
- [Tech Stack & Architecture](#-tech-stack--architecture)
- [Why Provider for State Management?](#-why-provider-for-state-management)
- [Offline Task Addition & Persistence](#-offline-task-addition--persistence)
- [Notification System & App States](#-notification-system--app-states)
- [Module 16 Assignment Implementation Status](#-module-16-assignment-implementation-status)
- [App Showcase & Screenshots](#-app-showcase--screenshots)
- [Project Structure](#-project-structure)
- [Getting Started & Local Setup](#-getting-started--local-setup)
- [Security & Environment Configuration](#-security--environment-configuration)

---

## 🌟 Project Overview

**FireTask** is a production-ready, full-featured Task Management application built with Flutter and Firebase as part of the **Module 16 Assignment: Firebase Push Notification + Local Notification** (Ostad Flutter Course).

The app features full **CRUD synchronization with Cloud Firestore**, **Firebase Authentication (Email/Password & Google Sign-In)**, an offline-first architecture, interactive swipe gestures, and a multi-layered notification system combining **Firebase Cloud Messaging (FCM)** with **`flutter_local_notifications`** to provide real-time foreground, background, and scheduled reminder alerts.

---

## 🛠 Tech Stack & Architecture

| Component | Technology | Purpose & Details |
| :--- | :--- | :--- |
| **Framework** | **Flutter (Dart 3)** | Cross-platform UI toolkit with responsive layout |
| **Backend & Database** | **Cloud Firestore** | Real-time NoSQL streaming database with multi-user isolation |
| **Authentication** | **Firebase Auth + Google Sign-In** | Email/Password, native Google OAuth, and persistent sessions |
| **Push Notifications** | **Firebase Cloud Messaging (FCM)** | Remote push alerts, device token registration, cloud messaging |
| **Local Notifications** | **`flutter_local_notifications`** | Foreground bridge banners, scheduled reminders, instant feedback |
| **State Management** | **`provider`** | Reactive separation of business logic and presentation layer |
| **Offline Persistence** | **Firestore Cache + `shared_preferences`** | On-device cache surviving app kills, restarts, and network drops |
| **Animations & Assets** | **Lottie Flutter** | Delightful vector animations for splash, auth, and empty states |
| **Networking** | **`url_launcher`** | External mail client redirection for feedback handling |

---

## 💡 Why Provider for State Management?

We selected **`provider`** as our primary state management solution for several key reasons:

1. **Official Flutter Recommendation**: Maintained and endorsed by the Flutter team as an intuitive wrapper around `InheritedWidget`.
2. **Seamless Reactive Streams**: Integrates cleanly with Firestore's real-time snapshots using `StreamSubscription` and `notifyListeners()`.
3. **Low Boilerplate, High Readability**: Unlike BLoC or Redux, `ChangeNotifierProvider` allows concise state updates without verbose event-state classes.
4. **Cross-Provider Synchronization**: Using `ChangeNotifierProxyProvider<AuthProvider, TaskProvider>`, `TaskProvider` automatically receives user login/logout events and re-binds real-time task streams dynamically without manual glue code.
5. **Lightweight & High Performance**: Rebuilds only the exact widgets listening to state changes via `Consumer` or `Provider.of<T>(context)`.

---

## 📴 Offline Task Addition & Persistence

The app is engineered with an **Offline-First Architecture**:

```
[User Creates/Modifies Task]
          │
          ├──► 1. Local Cache (`shared_preferences` / Firestore Memory) ──► Instant UI Update (0ms)
          │
          └──► 2. Cloud Firestore Offline Engine (Write Queue)
                    │
                    ├── If Online  ──► Sync to Cloud Firestore instantly
                    └── If Offline ──► Queued locally; automatically synced when reconnected
```

### How it works:
- **Firestore Offline Cache**: Initialized in `FirebaseService` with:
  ```dart
  _firestore.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  ```
- **Local Disk Fallback**: `LocalStorageService` persists the task list on disk using `shared_preferences`. Even if the device has zero internet connectivity, tasks are created, edited, marked done, and deleted immediately with zero UI freeze.
- **Auto-Sync**: As soon as the network returns, Firestore automatically commits the queued offline changes to the cloud.

---

## 🔔 Notification System & App States

Handling notifications across all Android app lifecycle states is the core requirement of this assignment.

### 1. Foreground State (App is Open & Visible)
- **Problem**: On Android, FCM remote notifications do **not** automatically show heads-up banner alerts when the app is actively in the foreground.
- **Solution (Foreground Bridge)**: 
  Our `NotificationService` intercepts the incoming FCM message stream:
  ```dart
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    // Intercept payload -> Render local notification banner
    showLocalNotification(
      title: message.notification?.title ?? '🔔 Task Alert',
      body: message.notification?.body ?? '',
      payload: message.data['taskId'],
    );
  });
  ```
  The user receives an instant banner alert without leaving the app.

---

### 2. Background State (App is Minimized)
- When the user minimizes or presses the home button, remote FCM notifications are delivered through the Android system tray automatically.
- Tapping the notification brings the app back to the foreground and triggers `FirebaseMessaging.onMessageOpenedApp`.

---

### 3. Terminated State (App is Killed / Swiped Away)
- When the app is terminated, incoming background push messages are handled by the top-level isolate function:
  ```dart
  @pragma('vm:entry-point')
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
  }
  ```
- When the user taps the notification on their lock screen or notification drawer:
  1. The app launches from scratch.
  2. `FirebaseMessaging.instance.getInitialMessage()` retrieves the launch payload.
  3. The app navigates to the **Task List Screen** and **highlights the specific task card** with a distinct black outline (`highlightedTaskId`).

---

## 📋 Module 16 Assignment Implementation Status

Below is the complete audit of all requirements specified in the **Module 16 Assignment Sheet**, demonstrating **100% implementation**:

### 1. Firebase Setup
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Firebase Core** | ✅ **DONE** | Configured `firebase_core: ^4.15.0` & initialized in `main.dart` |
| **Firebase Authentication** | ✅ **DONE** | Configured `firebase_auth: ^6.7.0` in `FirebaseService` & `AuthProvider` |
| **Cloud Firestore** | ✅ **DONE** | Configured `cloud_firestore: ^6.10.0` with real-time stream sync |
| **Firebase Cloud Messaging (FCM)** | ✅ **DONE** | Configured `firebase_messaging: ^16.7.0` with Android channel `task_channel` |

### 2. Authentication Flow
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Email Input with validation** | ✅ **DONE** | Regex email validation with centered error notification card |
| **Password Input** | ✅ **DONE** | Min 6-char validation with password obscure eye toggle icon |
| **Sign In Button** | ✅ **DONE** | `signInWithEmailAndPassword` via `AuthProvider` |
| **Google Sign-In Button** | ✅ **DONE** | 1-tap Google account chooser & `GoogleAuthProvider` credential linking |
| **Sign Up Option** | ✅ **DONE** | Smooth in-screen toggle between Login and Create Account |
| **Session Persistence** | ✅ **DONE** | User stays logged in across app close/reboot via `authStateChanges()` |

### 3. Task Management (CRUD & Cloud Firestore)
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **See All Tasks (Task List)** | ✅ **DONE** | Real-time task list in `TaskListScreen` with live counters |
| **Add New Task** | ✅ **DONE** | `AddTaskScreen` with title, notes, priority, category & calendar picker |
| **Edit Task** | ✅ **DONE** | `EditTaskScreen` with pre-filled inputs & live character counter (27/60) |
| **Delete Task** | ✅ **DONE** | Safe bottom sheet confirmation dialog (`DeleteConfirmationDialog`) |
| **Mark Task as Completed** | ✅ **DONE** | 1-tap checkbox or swipe right gesture with celebration feedback |
| **Task Priority (High, Med, Low)** | ✅ **DONE** | Visual color-coded priority pills (Red, Amber, Green) |
| **Set Due Date** | ✅ **DONE** | Interactive `showDatePicker()` with formatted date displays |
| **Firestore: Title Field** | ✅ **DONE** | Stored in document field `title` |
| **Firestore: Description Field** | ✅ **DONE** | Stored in document field `description` |
| **Firestore: Due Date Field** | ✅ **DONE** | Stored in document field `dueDate` (`Timestamp` / `DateTime`) |
| **Firestore: Priority Field** | ✅ **DONE** | Stored in document field `priority` |
| **Firestore: Completion Status** | ✅ **DONE** | Stored in document boolean `isCompleted` |
| **Firestore: Created Date** | ✅ **DONE** | Stored in document field `createdAt` |

### 4. Firebase Cloud Messaging (FCM Push Notifications)
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Setup FCM** | ✅ **DONE** | High-importance channel `task_channel` with notification permissions |
| **Get & Display Device FCM Token** | ✅ **DONE** | Viewable in Account screen modal with **1-click Copy** button |
| **Send Dummy / Test Notification** | ✅ **DONE** | Testable via Firebase Console or in-app test trigger buttons |
| **Task Reminder Message** | ✅ **DONE** | Formatted alerts ("Don't forget your task: Complete Flutter Assignment") |

### 5. Local Notification System (`flutter_local_notifications`)
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Package Integration** | ✅ **DONE** | `flutter_local_notifications: ^18.0.1` installed and configured |
| **Notification Channel** | ✅ **DONE** | `task_channel` (High importance, vibration, sound, lights) |
| **Receive Foreground FCM Message** | ✅ **DONE** | Listens to `FirebaseMessaging.onMessage` stream |
| **Show Local Notification Banner** | ✅ **DONE** | Displays heads-up banner via `_localNotifications.show(...)` |
| **Task Action Triggers** | ✅ **DONE** | Auto-triggered banners on task creation and completion |

### 6. App Lifecycle States Handling
| App State | Expected Assignment Behavior | Status | Implementation Details |
| :--- | :--- | :---: | :--- |
| **Foreground** | App is open: FCM arrives -> Intercept -> Show local notification banner | ✅ **DONE** | Handled in `NotificationService.initialize()` |
| **Background** | App minimized: OS system tray notification displayed automatically | ✅ **DONE** | Registered `@pragma('vm:entry-point') firebaseMessagingBackgroundHandler` |
| **Terminated** | App killed: Notification tap launches app and retrieves payload | ✅ **DONE** | Handled via `FirebaseMessaging.instance.getInitialMessage()` |

### 7. Notification Click & Navigation
| Assignment Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Notification Tap Detection** | ✅ **DONE** | Handled via `onDidReceiveNotificationResponse` & `onMessageOpenedApp` |
| **Navigate to Task & Highlight** | ✅ **DONE** | Navigates to `TaskListScreen` and highlights clicked task with **black border** |

### 8. Bonus & Extra Features
| Feature | Status | Details |
| :--- | :---: | :--- |
| **Task Search** | ✅ **DONE** | Real-time search query filtering by title, description, or category |
| **Status Filter Tabs** | ✅ **DONE** | Tabs for `All`, `Pending`, `Completed` with live count badges |
| **Due Date Reminders** | ✅ **DONE** | Timed alarms scheduled via `zonedSchedule` & 5s test reminder |
| **Categories** | ✅ **DONE** | Categorize into `Personal`, `Educational`, and `Work` |
| **Swipe Gestures** | ✅ **DONE** | Swipe Right = Mark Complete (Green), Swipe Left = Delete (Red dialog) |
| **In-App "Set Account Password"** | ✅ **DONE** | Google users can link an email password inside the Account screen |
| **"Share Your Feedback" Modal** | ✅ **DONE** | Account screen tile opens form redirecting to device email client |
| **Centered Error Cards** | ✅ **DONE** | Centered inline error cards between fields and action button |

---

## 📸 App Showcase & Screenshots

All high-resolution outputs are located in [`lib/Output Screens/`](lib/Output%20Screens/).

### 1. Authentication & Onboarding
| Splash Screen | Login Screen | Sign Up Screen | Forgot Password |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/splash%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/login%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/sign%20up%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/forgot%20passward%20screen.jpg" width="220" /> |

---

### 2. Task Management & Operations
| Task List Dashboard | Add Task Screen | Edit Task Screen | Delete Confirmation |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/Task%20List%20Screen.jpg" width="220" /> | <img src="lib/Output%20Screens/add%20task%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/edit%20task%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/delete%20task.jpg" width="220" /> |

---

### 3. Interactive Gestures, Search & Filters
| Swipe Right (Complete) | Swipe Left (Delete) | Filter & Sort Modal | Search Tasks |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/mark%20as%20complete%20using%20swipe%20right%20gesture.jpg" width="220" /> | <img src="lib/Output%20Screens/delete%20task%20using%20swipe%20left%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/filter%20task.jpg" width="220" /> | <img src="lib/Output%20Screens/search%20task.jpg" width="220" /> |

---

### 4. Account, Settings & Notifications
| Account Dashboard | In-App Set Password | Share Feedback | Push Notification Alert |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/profile%20screen.jpg" width="220" /> | <img src="lib/Output%20Screens/change%20password.jpg" width="220" /> | <img src="lib/Output%20Screens/share%20feedback'.jpg" width="220" /> | <img src="lib/Output%20Screens/notification.jpg" width="220" /> |

---

### 5. Firebase Cloud Firestore Database
| Cloud Firestore Live Tasks Collection |
| :---: |
| <img src="lib/Output%20Screens/Database%20output.png" width="850" /> |

---

## 📂 Project Structure

```
task_manager/
├── android/
│   ├── app/
│   │   ├── google-services.json.example   # Safe template for Firebase Android config
│   │   └── src/main/AndroidManifest.xml   # Notification permissions & intent queries
├── assets/                                # Lottie animations & vector assets
├── lib/
│   ├── config/
│   │   └── app_config.dart                # Central app config & feedback recipient email
│   ├── firebase_options.dart.example      # Safe template for Firebase options
│   ├── main.dart                          # App entry point, Providers & Theme setup
│   ├── models/
│   │   └── task_model.dart                # Task model with Firestore & JSON mapping
│   ├── providers/
│   │   ├── auth_provider.dart             # Authentication, Google Sign-In & password linking
│   │   └── task_provider.dart             # Task CRUD, filters, sorting, deduplication & state
│   ├── screens/
│   │   ├── add_task_screen.dart           # Task creation with interactive calendar
│   │   ├── edit_task_screen.dart          # Task editing with live character counter
│   │   ├── error_screen.dart              # Offline / network retry screen
│   │   ├── forgot_password_screen.dart    # Password reset email flow
│   │   ├── login_screen.dart              # Login & Sign Up with centered error card
│   │   ├── profile_screen.dart            # Modular Account screen with live statistics
│   │   ├── splash_screen.dart             # Clean branding splash screen
│   │   └── task_list_screen.dart          # Clean dashboard with swipeable cards
│   ├── services/
│   │   ├── firebase_service.dart          # Cloud Firestore CRUD & Auth singleton
│   │   ├── local_storage_service.dart     # SharedPreferences local disk cache
│   │   └── notification_service.dart      # FCM & flutter_local_notifications engine
│   ├── theme/
│   │   └── app_theme.dart                 # Design tokens, color palette, buttons & cards
│   └── widgets/
│       ├── app_logo.dart                  # Minimalist brand logo
│       ├── delete_confirmation_dialog.dart# Delete confirmation modal sheet
│       ├── fcm_token_bottom_sheet.dart    # FCM Token viewer, 1-click copy & test triggers
│       ├── feedback_bottom_sheet.dart     # Feedback form with mailto redirection
│       ├── filter_sort_bottom_sheet.dart  # Filter & sort bottom sheet
│       ├── set_password_bottom_sheet.dart # In-app password linking modal
│       └── task_card.dart                 # Swipeable task card with highlight border
├── pubspec.yaml                           # Project dependencies
└── README.md                              # Comprehensive project documentation
```

---

## 🚀 Getting Started & Local Setup

### Prerequisites
- Flutter SDK `^3.19.0` or higher
- Android SDK with API Level 23+ (Android 6.0+)
- Firebase Project configured on [Firebase Console](https://console.firebase.google.com/)

### Installation

1. **Clone the repository**:
   ```bash
   git clone <YOUR_GITHUB_REPOSITORY_URL>
   cd task_manager
   ```

2. **Install Flutter packages**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Copy `android/app/google-services.json.example` to `android/app/google-services.json` and insert your Firebase project credentials (or download directly from Firebase Console).
   - Copy `lib/firebase_options.dart.example` to `lib/firebase_options.dart` (or run `flutterfire configure`).

4. **Run the application**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```
   The built APK is saved to:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Security & Environment Configuration

For security reasons, all sensitive Firebase API keys, credentials, and private email addresses are **strictly excluded from source control via `.gitignore`**:
- `android/app/google-services.json` (Local only)
- `lib/firebase_options.dart` (Local only)
- `key.properties` / `*.keystore` (Local only)

Refer to `.gitignore` whenever you need to locate, modify, or restore private configurations.

---

## 👨‍💻 Author & Submission

- **Student / Developer**: Maruf Hossain
- **Assignment**: Module 16 Assignment (Firebase Push Notification + Local Notification)
- **Institution**: Ostad Flutter Course
- **Submission Date**: October 2026
