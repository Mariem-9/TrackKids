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

### Objectif 1 : Connecting the child’s phone to the parent account and sending GPS location data.

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