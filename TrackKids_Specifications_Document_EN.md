# **TrackKids – Project Specifications Document**

## 1. Project Overview

**Project Name:** TrackKids
**Type:** Mobile Application (Android & iOS)
**Technology:** Flutter, Dart, Firebase/SQLite

**Project Description:**
TrackKids is a parental control application designed to help parents monitor and manage their children’s digital activity. It provides features for managing screen time, blocking applications, filtering web content, tracking GPS location, and monitoring social media usage.

---

## 2. Objectives

The main goal is to develop an Android mobile application with two modules (Parent and Child), enabling:

* Real-time GPS location tracking of the child
* Basic app blocking
* Screen access control
* Secure web navigation
* Viewing a simple activity history

---

## 3. Project Scope

### 3.1 Included Features

* Parent authentication
* Parent–Child device association via a unique ID
* GPS location updates at fixed intervals
* Visual blocking of selected applications
* Manual screen blocking
* Web navigation through a secure WebView
* Simple activity history display

### 3.2 Excluded Features

* Monitoring of calls and SMS
* Analysis of message content
* Advanced AI-based web filtering
* iOS support (initially Android only)
* Advanced anti-theft features

---

## 4. System Actors

| Actor    | Description                                        |
| -------- | -------------------------------------------------- |
| Parent   | Main user who controls the child’s device settings |
| Child    | Device controlled by the parent                    |
| Firebase | Backend system for authentication and data storage |

---

## 5. Functional Description

### 5.1 Parent Application

* Secure sign-up and login
* Generation of a unique Child ID
* Display of the child’s GPS location on a map
* Selection of apps to block
* Activate/deactivate screen blocking
* View simple activity reports

### 5.2 Child Application

* Link device to Parent account
* Periodically send GPS location
* Monitor the current foreground app
* Display overlay for blocked apps
* Secure web navigation
* Log basic activity history

---

## 6. Functional Requirements

| ID   | Requirement                                           |
| ---- | ----------------------------------------------------- |
| FR-1 | System must allow the Parent to authenticate securely |
| FR-2 | System must allow Parent–Child device association     |
| FR-3 | System must display the child’s GPS location          |
| FR-4 | System must visually block selected apps              |
| FR-5 | System must allow manual screen blocking              |
| FR-6 | System must store activity logs in the database       |

**Key Functional Modules:**

1. **Screen Time Management**: Set daily usage limits, notifications for nearing limits.
2. **Application Blocking**: Block selected apps, schedule access.
3. **Web Content Filtering**: Block inappropriate websites, filter by categories.
4. **GPS Location Tracking**: Real-time tracking, location history.
5. **Activity Reports**: Track app usage, browsing history, generate reports.
6. **Social Media Control**: Restrict access, monitor usage.
7. **Device Security**: Locate device, remote lock or alert feature.

---

## 7. Non-Functional Requirements

* **Performance:** Smooth operation on Android devices
* **Security:** Secure data storage via Firebase
* **Usability:** Intuitive interface for parents
* **Reliability:** 99% backend uptime
* **Scalability:** Support multiple child profiles
* **Compatibility:** Android only (for MVP)

---

## 8. Technical Specifications

* **Frontend & Backend:** Flutter & Dart
* **Database:** Firebase Firestore / SQLite
* **Authentication:** Firebase Auth
* **Location Services:** Google Maps API / Flutter Location plugin
* **Notifications:** Firebase Cloud Messaging (FCM)

**Android Services:**

* Usage Stats
* Accessibility Service
* Overlay Window

**General Architecture:**

* Flutter mobile app (Parent + Child modules)
* Real-time communication via Firestore
* Android services for app monitoring and blocking

---

## 9. Project Constraints

* Developed by a single person
* Limited development time (1 week MVP)
* Simplified features for feasibility
* Compliance with privacy and data protection

---

## 10. Project Timeline

| Day   | Task                               |
| ----- | ---------------------------------- |
| Day 1 | Firebase setup + Parent & Child UI |
| Day 2 | GPS location functionality         |
| Day 3 | App blocking implementation        |
| Day 4 | Secure WebView navigation          |
| Day 5 | Screen blocking overlay            |
| Day 6 | Activity logs + testing            |
| Day 7 | Optimization + documentation       |

---

## 11. Project Deliverables

* Parent Application
* Child Application
* Firebase database
* Flutter source code
* Project report
* Functional demonstration

---

## 12. Validation Criteria

* Authentication works correctly
* Child location displayed on the map
* Selected applications are blocked visually
* Activity logs accessible
* Stable application without crashes

---

## 13. Simplified MVP Implementation Approach

All features are implemented according to a **Minimum Viable Product (MVP)** approach to ensure feasibility within a limited timeframe. Solutions prioritize **simplicity**, **stability**, and **functional demonstration**.

### 13.1 Authentication (Parent)

* **Implementation:** Firebase Authentication (Email & Password)
* **Simplifications:** No biometrics, social login, or advanced role management

### 13.2 Parent–Child Association

* **Implementation:** Unique static Child ID entered manually
* **Simplifications:** No QR codes, multi-child management, or email/SMS verification

### 13.3 GPS Location

* **Implementation:** Updates every 5 minutes when app is active
* **Simplifications:** No continuous background tracking, only last position stored

### 13.4 Application Blocking

* **Implementation:** Monitor foreground app via Usage Stats API, overlay visual block
* **Simplifications:** No device admin/deep system blocking

### 13.5 Screen Blocking

* **Implementation:** Full-screen overlay controlled via Firestore boolean
* **Simplifications:** No automated scheduling, no system lock

### 13.6 Web Filtering

* **Implementation:** WebView with fixed blacklist
* **Simplifications:** No network-wide filtering, no page content analysis

### 13.7 Activity Reports

* **Implementation:** Logs key events (blocked apps, screen block, GPS send) in Firestore
* **Simplifications:** No advanced statistics or graphs

### 13.8 Data Synchronization

* **Implementation:** Real-time via Firestore Streams
* **Simplifications:** No offline caching or queue management

### 13.9 Security & Privacy

* **Implementation:** Secure access via Firebase Auth, basic Firestore rules by Parent UID
* **Simplifications:** No application-level encryption, no advanced GDPR compliance

| Feature        | MVP Choice           | Objective                |
| -------------- | -------------------- | ------------------------ |
| Authentication | Firebase Auth simple | Minimal security         |
| Location       | Last position only   | Reduce complexity        |
| App Blocking   | Visual overlay       | Avoid Device Admin       |
| Web Filtering  | WebView + blacklist  | Basic control            |
| Reports        | Simple logs          | Functional demonstration |


