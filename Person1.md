| **Person**   | **Functional Area**                  | **Responsibilities / Tasks**                                                                                                                                                               | **Deliverables**                                                                                           |
| ------------ | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |------------------------------------------------------------------------------------------------------------|
| **Person 1** | **Screen Time & App Control**        | - Parent app: Manage screen time limits and app blocking UI<br>- Child app: Implement overlay for blocked apps<br>- Backend: Store and retrieve screen time settings and blocked apps list | - Screen time & app blocking fully functional<br>- Logs for blocked apps<br>- Screens/UI completed         |

---

### Objectif 1: Implement Screen Time Management

1. **Parent App**
    - Create UI to set daily usage limits for each child.
    - Store limits in Firebase Firestore (or SQLite).
    - Display current usage stats per app/device.

2. **Child App**
    - Monitor app usage locally using `app_usage` or `device_apps`.
    - Compare usage to limits set by parent.
    - Show overlay with message “App Blocked” when limit is reached.
    - Prevent child from bypassing the overlay.

3. **Backend**
    - Firestore collections:
      ```
      screen_time_limits (collection)
        └── {childId} (document)
            ├── appId: string
            ├── dailyLimitMinutes: int
            ├── usageTodayMinutes: int
            ├── lastUpdated: timestamp
      blocked_apps_logs (collection)
        └── {childId} (document)
            ├── appId: string
            ├── timestamp: timestamp
            ├── reason: string
      ```
    - Functions to read/write limits and logs.

---

### Objectif 2: App Blocking Feature

1. **Child App Overlay**
    - Implement `overlay_service.dart` to display a blocking screen.
    - Trigger overlay when:
        - App is on blocked list.
        - Daily screen time limit is reached.
    - Make overlay persistent until parent removes block or next day resets.

2. **Logging**
    - Record blocked app attempts in `blocked_apps_logs`.
    - Include timestamp and app ID.
    - Allow parent to view logs in `activity_report_page`.

---


