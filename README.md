# 📱 FireTask — Firebase Task Manager

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/State_Management-Provider-blue?style=for-the-badge" alt="Provider" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Assignment-Module%2016-orange?style=for-the-badge" alt="Module 16" />
</p>

---

## 🚀 Submission & Download

<p align="center">
  <a href="https://drive.google.com/file/d/1spDwMHTcGrLFLJmSqk9leb0rveAfFPzG/view?usp=sharing" target="_blank">
    <img src="https://img.shields.io/badge/📥_Download_Release_APK-Google_Drive-34A853?style=for-the-badge&logo=googledrive&logoColor=white" alt="Download APK from Google Drive" />
  </a>
</p>

| Parameter | Details | Status |
| :--- | :--- | :---: |
| **Course & Module** | Ostad Flutter Course — **Module 16 Assignment** | ✅ Completed |
| **Topic** | Firebase Push Notification + Local Notification | ✅ Implemented |
| **GitHub Repository** | [github.com/marufhossain19/FireTask](https://github.com/marufhossain19/FireTask) | 🚀 **Uploaded & Synced** |
| **Ostad Portal** | Assignment Submission | 🎯 **Submitted** |
| **Release APK** | [Google Drive Direct Download Link](https://drive.google.com/file/d/1spDwMHTcGrLFLJmSqk9leb0rveAfFPzG/view?usp=sharing) | 📦 Ready to Test |

---

## 📸 App Showcase & Output Screens

### 1. Authentication & Onboarding
| Splash Screen | Create Account (Sign Up) | Login Screen | Forgot Password |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/splash%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/sign%20up%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/login%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/forgot%20passward%20screen.jpg" width="200" /> |

### 2. Task Management, Dashboard & Error States
| Task List Dashboard | No Tasks (Empty State) | Add Task Screen | Edit Task Screen |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/Task%20List%20Screen.jpg" width="200" /> | <img src="lib/Output%20Screens/no%20task%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/add%20task%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/edit%20task%20screen.jpg" width="200" /> |

| Delete Confirmation | Error / Offline Screen | Live Task Search | Filter & Sort Options |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/delete%20task.jpg" width="200" /> | <img src="lib/Output%20Screens/error%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/search%20task.jpg" width="200" /> | <img src="lib/Output%20Screens/filter%20task.jpg" width="200" /> |

### 3. Interactive Gestures
| Swipe Right (Mark Complete) | Swipe Left (Delete Task) |
| :---: | :---: |
| <img src="lib/Output%20Screens/mark%20as%20complete%20using%20swipe%20right%20gesture.jpg" width="310" /> | <img src="lib/Output%20Screens/delete%20task%20using%20swipe%20left%20screen.jpg" width="310" /> |

### 4. Push & Local Notification System
| Foreground Alert Banner | FCM Test Trigger & Token Sheet |
| :---: | :---: |
| <img src="lib/Output%20Screens/notification.jpg" width="310" /> | <img src="lib/Output%20Screens/FCM%20test%20notification.jpg" width="310" /> |

### 5. Profile, Account & Settings
| Profile Screen | Account & Settings Card | Change Password | Share Feedback |
| :---: | :---: | :---: | :---: |
| <img src="lib/Output%20Screens/profile%20screen.jpg" width="200" /> | <img src="lib/Output%20Screens/account%20and%20settings%20card.jpg" width="200" /> | <img src="lib/Output%20Screens/change%20password.jpg" width="200" /> | <img src="lib/Output%20Screens/share%20feedback'.jpg" width="200" /> |

### 6. Cloud Firestore Real-Time Database
<p align="center">
  <img src="lib/Output%20Screens/Database%20output.png" width="850" alt="Cloud Firestore Database Output" />
</p>

---

## ✨ Key Features

- **🔄 Cloud Firestore Real-Time CRUD**: Real-time snapshot synchronization across devices with offline persistence caching.
- **🔔 Complete Notification Lifecycle**:
  - **Foreground**: Remote FCM intercepted and presented as heads-up local banner via `flutter_local_notifications`.
  - **Background**: Received via system tray notifications.
  - **Terminated**: App launch upon notification tap with automatic payload routing and task card highlighting.
- **🔐 Secure Dual Authentication**: Email/Password authentication & 1-tap Google Sign-In with persistent login sessions.
- **👆 Intuitive Swipe Gestures**: Swipe right (green) to complete tasks instantly; swipe left (red) for safe deletion confirmation.
- **🎯 Task Prioritization & Categorization**: Color-coded priorities (*High, Medium, Low*), custom categories (*Personal, Educational, Work*), and calendar due dates.
- **🔍 Search & Filter Tabs**: Instant search filtering, status tabs (*All, Pending, Completed*) with live task counters.
- **📴 Offline-First Reliability**: Task creation, editing, and status updates work seamlessly without internet connectivity and automatically sync upon reconnection.

---

## 🛠 Tech Stack

| Layer | Technologies |
| :--- | :--- |
| **Client** | Flutter (Dart 3), Material 3 Design |
| **Backend** | Google Cloud Firestore (NoSQL Streaming Database) |
| **Authentication** | Firebase Auth, Google Sign-In |
| **Notifications** | Firebase Cloud Messaging (FCM), `flutter_local_notifications` |
| **State Management** | `provider` (`ChangeNotifier`, `ChangeNotifierProxyProvider`) |
| **Offline Cache** | Firestore Persistence Cache + `shared_preferences` |
| **Animations** | Lottie Animations |

---

## 📂 Project Architecture

```
lib/
├── config/             # App configuration constants
├── models/             # Task data model & Firestore serialization
├── providers/          # AuthProvider & TaskProvider business logic
├── screens/            # Splash, Login, Task List, Add, Edit & Profile screens
├── services/           # FirebaseService, NotificationService & LocalStorage
├── theme/              # Color palette, typography & widget styles
├── widgets/            # Task card, swipe handlers, bottom sheets & dialogs
└── main.dart           # App root initialization & multi-provider setup
```

---

## 🚀 Getting Started

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/marufhossain19/FireTask.git
   cd FireTask
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**:
   - Place your `google-services.json` inside `android/app/`.
   - Update `lib/firebase_options.dart` (or run `flutterfire configure`).

4. **Run Application**:
   ```bash
   flutter run
   ```

---

## 👨‍💻 Developer & Submission Info

- **Student**: Md. Maruf Hossen
- **Course**: Ostad Flutter Course
- **Assignment**: Module 16 (Firebase Push Notification + Local Notification)
- **Repository**: [https://github.com/marufhossain19/FireTask](https://github.com/marufhossain19/FireTask)
- **App Download**: [Google Drive Link](https://drive.google.com/file/d/1spDwMHTcGrLFLJmSqk9leb0rveAfFPzG/view?usp=sharing)
