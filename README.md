# MyStudies – Smart Academic Organizer 🎓📱

**MyStudies** is a mobile application designed to unify academic processes into a single, integrated platform. [cite_start]It transforms institutional schedules (PDFs) into interactive calendars, captures assignment and exam details from Blackboard announcements using OCR, calculates GPA, and centralizes course resources[cite: 337, 338].

> [cite_start]**Project Status:** Graduation Project (CS471) - Jubail Industrial College.

---

## 📸 Screenshots

| Smart Schedule | Dashboard | GPA Calculator |
|:---:|:---:|:---:|
| <img src="assets/screenshots/calendar.png" width="200" alt="Calendar View" /> | <img src="assets/screenshots/dashboard.png" width="200" alt="Dashboard" /> | <img src="assets/screenshots/gpa.png" width="200" alt="GPA Calculator" /> |

*(Note: Replace the paths above with your actual screenshot paths)*

---

## ✨ Key Features

* [cite_start]**📅 Smart Schedule Import:** Automatically parses PDF schedule files to extract course names, times, days, and locations, creating an interactive calendar[cite: 348].
* [cite_start]**📷 OCR Deadline Scanner:** Extracts text from screenshots/photos of Blackboard announcements to automatically create calendar events with titles and reminders[cite: 349].
* [cite_start]**📊 GPA Predictor:** Calculates current Semester GPA and predicts the grades required to reach a specific target CGPA[cite: 350].
* [cite_start]**🔗 Centralized Resources:** Provides quick-access links to course groups (Telegram) and shared study materials[cite: 351].
* [cite_start]**📤 Export to iCal:** Generates `.ics` files compatible with Google Calendar and Apple Calendar[cite: 352].
* [cite_start]**🔔 Event Management:** Manual event creation, updates, and customizable reminders[cite: 353].

---

## 🛠️ Tech Stack & Architecture

[cite_start]The application follows a **Layered Architecture** using the **BLoC (Business Logic Component)** pattern[cite: 361].

* [cite_start]**Framework:** Flutter & Dart SDK 3.0+[cite: 20, 387].
* [cite_start]**State Management:** BLoC / Cubit[cite: 361].
* [cite_start]**Local Database:** SQLite (`sqflite`) for offline-first storage[cite: 388].
* [cite_start]**OCR Engine:** Google ML Kit[cite: 389].
* [cite_start]**PDF Processing:** Dart-based parsing / Python backend integration[cite: 420].
* [cite_start]**Supported Platforms:** Android (10+) & iOS (16+)[cite: 358].

---

## 🚀 Installation & Setup

### Prerequisites
* [cite_start]**OS:** Windows 10/11, macOS 10.14+, or Linux[cite: 15].
* [cite_start]**Tools:** VS Code (Recommended) or Android Studio[cite: 24].
* [cite_start]**SDKs:** Flutter SDK (3.0+), Java JDK (11+)[cite: 20, 22].

### Step-by-Step Guide

1.  **Clone the Repository**
    ```bash
    git clone [PROJECT_REPO_URL] mystudies
    cd mystudies
    ```
    *[cite: 115, 120]*

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```
    *[cite: 125]*

3.  **Configure Environment**
    Create `lib/config/environment.dart` if it doesn't exist:
    ```dart
    class Environment {
      static const String appName = 'MyStudies';
      static const String version = '1.0.0';
      static const bool isProduction = false;
    }
    ```
    *[cite: 131-138]*

4.  **Run the Application**
    Ensure a device/emulator is connected, then run:
    ```bash
    flutter run
    ```
    *[cite: 146]*

---

## 📂 Project Structure

```text
mystudies/
├── lib/
│   ├── core/               # Shared infrastructure (Theme, DB, Utils) [cite: 425]
│   ├── features/
│   │   ├── calendar/       # Event management & Logic [cite: 450]
│   │   ├── gpa/            # GPA Calculator & Predictor [cite: 478]
│   │   ├── notifications/  # Notification services [cite: 496]
│   │   ├── resources/      # Course links & materials [cite: 506]
│   │   ├── schedule/       # PDF Import & Parsing [cite: 521]
│   │   ├── settings/       # App preferences [cite: 555]
│   │   └── splash/         # Startup screen [cite: 561]
│   └── main.dart           # Entry point [cite: 563]
├── android/                # Android native config [cite: 263]
├── ios/                    # iOS native config [cite: 264]
└── pubspec.yaml            # Dependencies [cite: 270]
```
👥 Authors (Team Members)

Asim Alzahrani (ID: 421900453) 


Mustafa Al Qattan (ID: 441101247) 


Majed Almutairi (ID: 431900118) 


Abdulaziz Alghamdi (ID: 421901508) 


Turki Alshaikh (ID: 422100018) 


Supervisor: Mohhamed Yassine El Amrani 

📄 License
This project was developed for academic purposes at Jubail Industrial College. All rights reserved to the development team.


