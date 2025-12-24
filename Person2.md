
| **Person**   | **Functional Area**                  | **Responsibilities / Tasks**                                                                                                                                                               | **Deliverables**                                                                                           |
| ------------ | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |------------------------------------------------------------------------------------------------------------|
| **Person 1** | **Screen Time & App Control**        | - Parent app: Manage screen time limits and app blocking UI<br>- Child app: Implement overlay for blocked apps<br>- Backend: Store and retrieve screen time settings and blocked apps list | - Screen time & app blocking fully functional<br>- Logs for blocked apps<br>- Screens/UI completed         |
| **Person 2** | **GPS Location & Device Security**   | - Parent app: Display child’s location on map<br>- Child app: Periodically send GPS coordinates<br>- Implement device anti-theft (locate phone)                                            | - Real-time GPS tracking working<br>- Last known location logs<br>- Basic device security features implemented |
| **Person 3** | **Web Filtering & Activity Reports** | - Parent app: View activity reports (app usage, blocked attempts)<br>- Child app: Secure WebView with blacklist<br>- Backend: Store activity logs, sync with parent                        | - Web filtering functional<br/> - Activity logs stored and displayed<br/>- Firebase integration completed       |

### Create Firebase Project

1. **Go to Firebase Console :** _https://console.firebase.google.com/u/1/?pli=1_
2. Click Add project : **_TrackKids_**
   → **Project ID** : _trackkids-e494b_
3. Enable Google Analytics 
4. Add App → Android → Register Android App → **Package name :** _com.example.trackkids_
5. Download google-services.json → Place it here: **_trackkids/android/app/google-services.json_**
6. Open **_android/settings.gradle_** → Add inside **_pluginManagement {}_**:
```
plugins {
    ...
    id("com.google.gms.google-services") version "4.4.4" apply false
}
```
7. Open **_android/app/build.gradle_** → Add:
```
plugins {
    ...
    id("com.google.gms.google-services")
}
```
8. Open **_pubspec.yaml_** → Add Flutter dependencies:
```
dependencies:
  firebase_core: ^3.8.0
  firebase_auth: ^5.5.0
  cloud_firestore: ^5.6.0
```
| Firebase Service            | Why                             |
| --------------------------- | ------------------------------- |
| **Firebase Core**           | Required for any Firebase usage |
| **Firebase Authentication** | Identify the parent             |
| **Cloud Firestore**         | Store child & location data     |
``` bash
flutter pub get
```
9. Open **_lib/main.dart_** → Initialize Firebase in Flutter :

   * Make main() async
   * Call Firebase.initializeApp()
   * Import firebase_core
``` 
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const TrackKidsApp(),
    ),
  );
}
```
10. **Enable Firebase Services in Console:** Go to Firebase Console → TrackKids project → 
Build → Authentication → Get Started → Email/Password → ENABLE
11. Build → Firestore → Create database → Standard mode → **Database ID:** _default_ → **Location:**_nam5 (United States)_
    → Create children Collection

```   
children (collection)
    └── {childId} (document)
    ├── parentId: string       // UID of the parent
    ├── latitude: double       // current latitude
    ├── longitude: double      // current longitude
    ├── lastUpdated: timestamp // last GPS update time
``` 
12. **Use Firestore Emulator (local, no billing)** → Install Firebase Emulator
``` bash
npm install -g firebase-tools
firebase login
firebase init emulators
```
**Emulators Setup**
* Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices. Authentication Emulator, Firestore Emulator
* Which port do you want to use for the auth emulator? 9099
* Which port do you want to use for the firestore emulator? 8080
* Would you like to enable the Emulator UI? Yes
* Which port do you want to use for the Emulator UI (leave empty to use any available port)?
* Would you like to download the emulators now? Yes
``` bash
firebase emulators:start
```
| Emulator       | Host:Port      | Emulator UI Link                                                   |
| -------------- | -------------- | ------------------------------------------------------------------ |
| Authentication | 127.0.0.1:9099 | [http://127.0.0.1:4000/auth](http://127.0.0.1:4000/auth)           |
| Firestore      | 127.0.0.1:8080 | [http://127.0.0.1:4000/firestore](http://127.0.0.1:4000/firestore) |
> Emulator UI: http://127.0.0.1:4000

12. Open **_lib/main.dart_** → Connect to the Firebase Emulators :
``` 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

...
// ===== Connect to Firebase Emulators =====
  // Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  // Auth Emulator
  FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
...

```
13. Add **_lib/features/test/test_firebase_page.dart_** File

**What this does:**
* Adds a new document to the children collection with the proper fields (parentId, latitude, longitude, lastUpdated)
* Shows a SnackBar confirming the child was added
* Prints the document ID to the console
* Fully works with Firestore Emulator — no billing required
> Open the Emulator UI at http://127.0.0.1:4000/firestore → You should see the new child document appear

---
### Objectif 1 : Connecting the child’s phone to the parent account and sending GPS location data
#### 1. Firestore Structure Definition
I created a central constant for your Firestore collection name (children) instead of typing the string "children" everywhere in your code.

> Any feature that needs to access the children collection can now use this constant.

#### 2. Add a Child Model
It represents a child’s data in the app as a Dart object.

* When you fetch child data from Firestore :
```
ChildModel child = ChildModel.fromMap(doc.data()!);
```

* When you send child data to Firestore :
```
_firestore.collection('children').doc(child.childId).set(child.toMap());
```

> Keeps code clean, strongly typed, and less error-prone.

#### 3. GPS Location Tracking (Child Device)
I implemented secure real-time GPS tracking from the child’s device and synced it with Firebase using:
* geolocator package
* Android location permissions
* Firebase Firestore updates

**How it works:**
1. App checks if GPS is enabled
2. Requests location permission
3. Reads current latitude & longitude
4. Sends data to Firestore

🚨 Add dependency : geolocator package in **_pubspec.yaml_**
```
dependencies:
  geolocator: ^11.0.0
```
🚨 Add Android location Permissions in **_android/app/src/main/AndroidManifest.xml_**
```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```
> Android permissions allow location tracking in compliance with system security.

✨ To verify that  **_LocationService + ChildModel + Firestore integration_** is working correctly i created
**_test_location_page.dart_** file.

**What this does:**
1. Create a ChildModel object
2. Calls your LocationService.
3. Checks location permissions on the device.
4. Reads the current GPS latitude & longitude.
5. Updates Firestore
6. Reads the child document from Firestore. 
7. Converts it back into a ChildModel object. 
8. Confirms that the location was saved correctly.
9. Shows the current GPS coordinates on screen. 
10. Prints the same data to the console for debugging.

#### 4. Child–Parent Pairing Feature
I implemented a secure pairing mechanism using Firebase that links a child’s device to a parent account via a unique ID.

Think of it as the “pairing manager”: it ensures that when a child device starts, it knows which parent it belongs to and sets up the document in Firestore so location and activity data can be stored.

**How it works:** This file pairs a child device to a parent account in Firebase and provides a way to fetch child data as a typed object so the app can track location and other activity safely.


✨ To verify that  **_pairing_** is working correctly i created
**_test_pairing_page.dart_** file.
1. Parent sign-in (anonymous for testing)
2. Calls ChildPairingController.pairChildWithParent()
3. Creates a ChildModel object with childId, parentId, and null GPS values 
4. Writes it to Firestore (children/testChild001)
5. Reads the Firestore document back as a typed ChildModel 
6. Confirms the data is saved correctly
7. Shows a SnackBar on the screen 
8. Prints the document data in the console 
9. Gives immediate feedback for debugging


🚨 Allow cleartext traffic for emulator in **_android/app/src/main/AndroidManifest.xml_**
```
<application
    android:name="io.flutter.app.FlutterApplication"
    android:label="trackkids"
    android:icon="@mipmap/ic_launcher"
    android:usesCleartextTraffic="true">
```
#### 5. Child Pairing User Interface
I created a clean UI for the child to pair their device with the parent account
where : The child enters the ID → Clicks “Pair” → Receives confirmation.

✨ To test **_ChildPairingPage.dart_** i make it the **_home page_** of your Flutter app for now.

* The app should launch directly on Child Pairing Page.
* You should see:
  * TextField: Enter Child ID
  * Button: Pair
  * SnackBar will appear after pairing
* Enter a test child ID (e.g., testChild001).
* Click Pair.
* Check the SnackBar → should say Child paired successfully.

🛠️ To switch between different test pages (or production pages) **_without editing main.dart every time_**, The cleanest way to do this in Flutter is to use **_AppRoutes_** with named routes, instead of commenting/uncommenting home.

---
### Objectif 2 : Automatically route the user to the correct home page (Parent UI vs Child UI) based on their role stored in Firebase.
✨ This eliminates the need to manually change initialRoute every time we want to test.
On launch, **_RoleRouter_** checks Firebase.

| If user is | App opens                     |
| ---------- |-------------------------------|
| Parent     | Parent Dashboard              |
| Child      | Child Monitoring (GPS sender) |
| Not paired | Welcome Page                  |

_**The role_router.dart**_ file is like the traffic controller of the app:
it decides which page the user should see when they open the app based on their role or pairing status.

**WelcomePage** work as a role selection page with two buttons: “Parent” and “Child.”

* **_Parent button:_** signs in anonymously (for now) and navigates to ParentDashboardPage.
* **_Child button:_** navigates to ChildPairingPage.

After pairing/sign-in, the **_RoleRouter_** will automatically detect the role next time the app launches.

![Welcome Page](assets/screenshots/welcome_page.png)

**Behavior:**
1. App launches → RoleRouter → if not paired → WelcomePage.
3. Click Parent → anonymously signs in → navigates to ParentDashboardPage.
5. Click Child → navigates to ChildPairingPage to pair with parent.
7. Next launch → RoleRouter detects role automatically → skips welcome page.

✨ Things to test :

✅ Launch the app for the first time → you should see the WelcomePage.

✅ Tap Parent clicks “I am a Parent” → opens a dialog to enter a Child ID → clicks Pair Child 
   → signs in anonymously + writes child to Firestore. → navigates to ParentDashboardPage.

✅ Close the app and reopen → RoleRouter automatically shows ParentDashboardPage.

✅ Repeat with Child → pair with parent → close and reopen → RoleRouter automatically shows AppMonitorPage.

---
### Objectif 3 : Allow the parent to see the child’s location on a map in real time .

#### 1. Parent Location Visualization (Map)
Create a Parent Map Page that:
* Shows Google Map
* Reads child location from Firestore
* Displays a marker at the child’s GPS position
* Updates when Firestore data changes (ready for real-time later)
```
lib/features/parent/location/
├── child_location_page.dart
      └── Reads child location from Firestore
       └── Converts Firestore data → ChildModel
        └── Exposes a Stream (real-time ready)
└── child_location_controller.dart
      └── Display Google Map
       └── Show child marker
        └── React to Firestore updates
```
🛠️ Add Route in **_app_routes.dart_**.

🚨 Add **_Google Maps_** dependency in **_pubspec.yaml_**
```
dependencies:
  google_maps_flutter: ^2.6.0
```
🚨 To Enable Google Maps SDK & Get API Key (Android) :

1. Go to : https://console.cloud.google.com/welcome?authuser=1&project=trackkids-e494b
2. Select the correct project : _**TrackKids**_
3. **Enable “Maps SDK for Android”** : APIs & Services → Library
   → Maps SDK for Android → Enable
4. **Get your SHA-1 fingerprint** : 
```
cd android
.\gradlew.bat signingReport
```
this will appear : 
```
> Task :app:signingReport
Variant: debug
Config: debug
Store: C:\Users\user\.android\debug.keystore
Alias: AndroidDebugKey
MD5: 9F:34:47:FC:F2:9B:44:E3:E6:A3:85:B6:A6:8B:0E:68
SHA1: 7D:42:F0:43:93:82:C8:A1:F4:24:63:48:A3:A9:D4:BF:FE:3D:94:ED
SHA-256: BD:80:FF:81:01:12:64:28:78:24:81:8D:5D:06:75:9A:97:EB:4D:07:B4:56:F1:F7:EA:84:98:BC:C1:F2:70:40
Valid until: Friday, November 26, 2055
```
5. Copy this exact SHA-1 Key from terminal output: 
**_7D:42:F0:43:93:82:C8:A1:F4:24:63:48:A3:A9:D4:BF:FE:3D:94:ED_**
6. **Create an API Key** : APIs & Services → Credentials
   → CREATE CREDENTIALS → API key → Google will generate a key :
   **_AIzaSyCUYAItOs4N6lrjipgjuRDLgwQ0MPHm2Hw_**
7. **Restrict API usage** : Click the API key you just created  →
   Select Android apps → Add an item  → **Package Name:** Enter **_com.example.trackkids_**
   → **SHA-1 fingerprint:** **_7D:42:F0:43:93:82:C8:A1:F4:24:63:48:A3:A9:D4:BF:FE:3D:94:ED_**
   → Done → Select Restrict key → Choose Maps SDK for Android → Save
8. **Add API Key to Flutter Android App** : Open **_android/app/src/main/AndroidManifest.xml_**
```
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCUYAItOs4N6lrjipgjuRDLgwQ0MPHm2Hw"/>
```
9. Go to the Firebase Console → Click the Gear Icon (Project Settings).
   → Scroll down to Your Apps →  Android app → Click Add fingerprint and paste the same SHA-1 code.
10. Download again google-services.json → Place it here: **_trackkids/android/app/google-services.json_**

🚨 **Error : You downloaded XR images (for VR/AR) but not the real Google Play phone images.
Maps + Firebase will not work on XR images.**
```
cd C:\Users\user\AppData\Local\Android\Sdk\cmdline-tools\latest\bin
sdkmanager --version
sdkmanager "system-images;android-34;google_apis_playstore;x86_64"
```
Open Android Studio → Device Manager → Create Device → Pixel 7 → Then select:
* Android 14
* Google Play
* x86_64

✨ To test : Add it to app-routes then :

✅ Tap Parent clicks “I am a Parent” → opens a dialog to enter a Child ID : **_testChild001_** → clicks Pair Child
→ signs in anonymously + writes child to Firestore. → navigates to ParentDashboardPage.

✅ Close the app

✅ Repeat with Child → pair with parent 

❌ Child is not sending GPS automatically yet

🚨 Nothing is telling the child device to: _“Start sending your GPS every X seconds.”_

**That must start right after pairing succeeds.**

🛠️ We already created: **_services/location_service.dart_** Which has:
  _**Future<void> sendLocation(String childId)**_ → We just need to turn it into a repeating background tracker.

✅ Location of the child sent to database every **_30 seconds automatically_**

💡To see live location updates during testing, both devices (child and parent) must be running at the same time.
* Launch two Android emulators
  1. Open Android Studio → AVD Manager.
  2. Create two emulators (e.g., Pixel_7_Child and Pixel_7_Parent).
  3. Start both emulators at the same time.
* Open two terminal for both Emulators

✅ parentLocation : map apper with a marker on the location of chld 

---
### Objectif 4 : Allow the parent to see the child’s location on a map in real time and locate the device in case of loss or theft.

**Real-Time Tracking**

* Listen to Firestore updates
* Update the map when GPS changes

**Locate Device (Anti-Theft)**

* Button: “Locate Phone”
* Fetch and display last known location
* (Optional MVP+) Trigger refresh from child device

**Location Logs (Optional but strong)**

* Store previous locations
* Show last known location/time