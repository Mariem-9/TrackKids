# TrackKids

**TrackKids** is a parental control application developed with **Flutter**. It allows parents to manage screen time, block apps, filter web content, locate their children, and monitor activity to ensure a safe digital environment.  

---

## **Features**

- **Screen Time Management:** Set daily usage limits for your children’s devices.  
- **Web Content Filtering:** Block access to inappropriate websites or content.  
- **App Blocking:** Restrict the use of specific applications.  
- **GPS Location Tracking:** Track your child’s device location in real-time.  
- **Activity Reports:** View history of app usage, browsing history, calls, and SMS.  
- **Social Media Control:** Manage access to platforms like Instagram, Snapchat, etc.  
- **Phone Security:** Locate your device in case of theft.  

---

## **Tech Stack**

- **Frontend & Backend:** Flutter  
- **Language:** Dart  
- **Database:** Firebase / SQLite (choose depending on your implementation)  
- **Maps & Location Services:** Google Maps API / Flutter Location plugin  
- **Authentication:** Firebase Auth  

---

## **Installation**

1. **Clone the repository:**  
```bash
git clone https://github.com/<your-username>/TrackKids.git
cd TrackKids
````

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Run the app:**

```bash
flutter run
```

---

## **Folder Structure**

```
TrackKids/
├── android/         # Android native code
├── ios/             # iOS native code
├── lib/             # Flutter source code
│   ├── screens/     # UI screens
│   ├── models/      # Data models
│   ├── services/    # API / Firebase / location services
│   ├── widgets/     # Reusable widgets
│   └── main.dart    # Entry point
├── assets/          # Images, icons, fonts
├── pubspec.yaml     # Flutter configuration
└── README.md
```
