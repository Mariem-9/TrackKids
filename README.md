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

## **Folder Structure**

```
trackkids/
│
├── android/                # Configuration Android native
├── ios/                    # (non utilisé – Android only)
├── lib/
│   ├── main.dart
│   │
│   ├── core/               # Logique commune
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_strings.dart
│   │   │   └── firestore_paths.dart
│   │   │
│   │   ├── utils/
│   │   │   ├── permissions_helper.dart
│   │   │   └── validators.dart
│   │   │
│   │   └── widgets/
│   │       ├── custom_button.dart
│   │       ├── loading_widget.dart
│   │       └── error_widget.dart
│   │
│   ├── models/             # Modèles de données
│   │   ├── parent_model.dart
│   │   ├── child_model.dart
│   │   └── activity_model.dart
│   │
│   ├── services/           # Accès aux services externes
│   │   ├── firebase_service.dart
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── app_block_service.dart
│   │   ├── overlay_service.dart
│   │   └── webview_service.dart
│   │
│   ├── features/           # Fonctionnalités par rôle
│   │
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   ├── register_page.dart
│   │   │   ├── auth_controller.dart
│   │   │   ├── welcome_page.dart
│   │   │   └── role_router.dart
│   │
│   │   ├── parent/
│   │   │   ├── dashboard/
│   │   │   │   ├── parent_dashboard_page.dart
│   │   │   │   └── parent_dashboard_controller.dart
│   │   │   │
│   │   │   ├── child_management/
│   │   │   │   ├── generate_child_id_page.dart
│   │   │   │   └── child_management_controller.dart
│   │   │   │
│   │   │   ├── location/
│   │   │   │   ├── child_location_page.dart
│   │   │   │   └── child_location_controller.dart
│   │   │   │
│   │   │   ├── app_blocking/
│   │   │   │   ├── app_block_page.dart
│   │   │   │   └── app_block_controller.dart
│   │   │   │
│   │   │   ├── reports/
│   │   │   │   ├── activity_report_page.dart
│   │   │   │   └── activity_report_controller.dart
│   │   │
│   │   ├── child/
│   │   │   ├── pairing/
│   │   │   │   ├── child_pairing_page.dart
│   │   │   │   └── child_pairing_controller.dart
│   │   │   │
│   │   │   ├── monitoring/
│   │   │   │   ├── app_monitor_page.dart
│   │   │   │   └── app_monitor_controller.dart
│   │   │   │
│   │   │   ├── web/
│   │   │   │   ├── safe_browser_page.dart
│   │   │   │   └── web_controller.dart
│   │   │   │
│   │   │   └── overlay/
│   │   │       └── block_overlay_page.dart
│   │   │
│   │   ├── test/
│   │   │   ├── test_firebase_page.dart 
│   │   │   └── ....
│   │   
│   ├── routes/
│   │   └── app_routes.dart
│   │
│   └── providers/
│       ├── theme_provider.dart
│       ├── auth_provider.dart
│       ├── parent_provider.dart
│       └── child_provider.dart
│
├── pubspec.yaml
└── README.md
```
---

## 🎨 Theme & Palette Management

This project uses a dynamic Theme Extension system to manage multiple color palettes. This allows us to switch between the three predefined brand palettes (Orange/Slate, Earthy/Sage, Soft Sunset) at runtime without restarting the app.

### 📂 Architecture

* **_lib/core/constants/app_colors.dart:_** Defines the ProjectColors class (ThemeExtension) and the static palette presets.
* **_lib/providers/theme_provider.dart:_** Manages the state of the current theme and provides the ThemeData to the app.
* **_lib/main.dart:**_ Listens to the provider to rebuild the app when the palette changes

### How to Use
**1. Accessing Colors in Widgets** : To use a color from the current active palette, use **_Theme.of(context)_**. 

🛑 Do not hardcode hex values in your features.

```
@override
Widget build(BuildContext context) {
// Access the custom palette extension
final palette = Theme.of(context).extension<ProjectColors>()!;

return Scaffold(
backgroundColor: palette.background,
appBar: AppBar(
backgroundColor: palette.primary,
title: Text("TrackKids", style: TextStyle(color: palette.neutral)),
),
);
}
```

**2. Switching the Palette** : To change the palette (e.g., from a settings page), call the updatePalette method from the ThemeProvider.
```
// Example: Switching to the Earthy/Sage palette (Image 2)
Provider.of<ThemeProvider>(context, listen: false)
.updatePalette(ProjectColors.paletteTwo);
```

3. Adding a New Palette :If you want to add a fourth palette:

* Go to lib/core/constants/app_colors.dart.
* Add a new static const instance of ProjectColors with your new hex codes.

 ✨ **_It will immediately be available to the ThemeProvider_**