# Visitor Management Mobile Application (Sumadhura)

A modern, responsive, and user-friendly Visitor Management mobile application developed with **Flutter** and **Dart**, strictly adhering to **Clean Architecture**, **BLoC (Business Logic Component)** state management, and **Domain-Driven Use Cases**.

Designed for front-desk and security personnel across residential projects to streamline visitor registration, QR code generation & scanning, and visit lifecycle tracking (`Registered` ➔ `Checked In` ➔ `Checked Out`).

---

## 📱 Features & Highlights

### 1. Interactive Dashboard
- **Calculated Today's Metrics:**
  - **Total Visitors Today:** Count of visitors registered today based on local device date.
  - **Currently Checked In:** Visitors currently on-site (`Checked In`).
  - **Checked Out Today:** Visitors who completed their visit today.
- **Quick Shortcuts:** Direct navigation to *Register Visitor*, *Visitor Directory*, and *QR Code Scanner*.
- **Recent Visitors Preview:** At-a-glance recent visitor activity with direct actions.

### 2. Visitor Registration & Management (Full CRUD)
- **Form Fields & Validations:**
  - **Visitor Name:** Required text.
  - **Mobile Number:** Required, strictly validated to exactly 10 numeric digits.
  - **Email Address:** Optional, validated with standard email regex if provided.
  - **Visitor Type:** Dropdown selection (*Customer*, *Vendor*, *Other*).
  - **Project Location:** Dropdown selection (*Project A*, *Project B*, *Project C*).
  - **Purpose of Visit:** Required description.
- **Default Status:** Initial status is set to `Registered`.
- **Edit & Delete:** Update visitor details anytime or delete with an `AlertDialog` confirmation.

### 3. QR Code Pass Generation & Camera Scanning
- **QR Code Generation:** High-resolution QR code dynamically rendered with `qr_flutter` using the unique `visitor.id`.
- **QR Code Scanning:** Fast camera scanning via `mobile_scanner` with a custom viewfinder overlay, flashlight/torch toggle, and camera switcher.
- **Scanner Guardrails & Feedback:**
  - Duplicate scan callback debouncing (prevents multiple scans within 2 seconds).
  - User-friendly error SnackBar when an invalid or non-existent QR code is detected.
  - Immediate lookup and automatic navigation to the visitor's profile & action screen upon scanning.

### 4. Check-In / Check-Out Business Rules
- **Strict Status Lifecycle:** `Registered` ➔ `Checked In` ➔ `Checked Out`.
- **Business Rule Enforcement:**
  - Visitors cannot check out before checking in.
  - Visitors cannot check in twice.
  - Completed visits (`Checked Out`) cannot check in again.
- **Timestamps:** Automatic capture of `created_at`, `check_in_time`, and `check_out_time` in ISO-8601 format with local timezone formatting.
- **Reactive Synchronization:** Status changes and dashboard counts update instantly across all screens without reloading or restarting the app.

### 5. Bonus Features Implemented
- **Multi-Filter Chips:** Filter visitors by Project (*Project A, B, C*) and Status (*Registered, Checked In, Checked Out*).
- **Search Bar:** Real-time local search by visitor name or 10-digit mobile number.
- **Pull-to-Refresh:** Smooth swipe-to-refresh on both Dashboard and Visitor Directory.
- **Automated Unit & Widget Tests:** Automated test suite covering use cases, business rules, and form validators.

---

## 🏛️ Clean Architecture Structure

The application is structured in three strictly decoupled layers:

```
lib/
├── core/                                 # Shared primitives, styling, utilities
│   ├── constants/
│   │   ├── api_constants.dart            # Configurable base URL & endpoints
│   │   └── app_constants.dart            # Statuses, types, project locations
│   ├── error/
│   │   ├── exceptions.dart               # Data layer exception classes
│   │   └── failures.dart                 # Domain failure abstractions
│   ├── theme/
│   │   └── app_theme.dart                # Material 3 Theme & status colors
│   └── utils/
│       ├── date_formatter.dart           # Device local date comparator & formats
│       └── validators.dart               # 10-digit mobile, email, required checks
│
├── features/visitor_management/
│   ├── domain/                           # Pure business logic (No Flutter dependencies)
│   │   ├── entities/
│   │   │   ├── visitor.dart              # Core visitor entity
│   │   │   └── dashboard_stats.dart      # Dashboard metrics entity
│   │   ├── repositories/
│   │   │   └── visitor_repository.dart   # Abstract repository contract
│   │   └── usecases/
│   │       ├── get_visitors_usecase.dart
│   │       ├── get_visitor_by_id_usecase.dart
│   │       ├── register_visitor_usecase.dart
│   │       ├── update_visitor_usecase.dart
│   │       ├── delete_visitor_usecase.dart
│   │       ├── check_in_visitor_usecase.dart
│   │       ├── check_out_visitor_usecase.dart
│   │       └── get_dashboard_stats_usecase.dart
│   │
│   ├── data/                             # Data source & model implementations
│   │   ├── models/
│   │   │   └── visitor_model.dart        # JSON serialization & Entity mapper
│   │   ├── datasources/
│   │   │   └── visitor_remote_data_source.dart # Dio client + persistent fallback store
│   │   └── repositories/
│   │       └── visitor_repository_impl.dart    # Implements domain repository
│   │
│   ├── di/
│   │   └── injection.dart                # GetIt dependency injection registry
│   │
│   └── presentation/                     # State management & UI widgets
│       ├── bloc/
│       │   ├── visitor_bloc.dart         # Handles CRUD, filters, check-in/out
│       │   ├── visitor_event.dart        # BLoC events
│       │   └── visitor_state.dart        # BLoC states with copyWith
│       ├── screens/
│       │   ├── main_navigation_screen.dart # Bottom Navigation bar container
│       │   ├── dashboard_screen.dart       # Metrics & quick actions
│       │   ├── visitor_list_screen.dart    # Search, filter chips, list
│       │   ├── visitor_form_screen.dart    # Register & Edit form
│       │   ├── visitor_details_screen.dart # QR pass display & visit actions
│       │   └── qr_scanner_screen.dart      # Camera preview & QR scanner
│       └── widgets/
│           ├── custom_button.dart
│           ├── custom_dropdown.dart
│           ├── custom_text_field.dart
│           ├── dashboard_stat_card.dart
│           ├── visitor_card.dart
│           ├── status_chip.dart
│           ├── confirm_dialog.dart
│           ├── loading_view.dart
│           └── empty_state_view.dart
│
└── main.dart                             # App initialization & MultiBlocProvider
```

---

## 🛠️ State Management Approach (BLoC)

We chose **flutter_bloc** (`VisitorBloc`) because:
1. **Unidirectional Data Flow:** Predictable state progression driven by immutable events (`LoadVisitorsEvent`, `SearchVisitorsEvent`, `CheckInVisitorEvent`, etc.).
2. **Separation of Concerns:** Business logic lives entirely inside Use Cases, while the BLoC orchestrates state changes and UI stays purely declarative.
3. **Immediate Cross-Screen Synchronization:** When a visitor is checked in or edited, the single source of truth (`VisitorBloc`) emits an updated `VisitorLoadedState`, simultaneously updating the **Dashboard counts**, the **Visitor List**, and the **Visitor Details** view without requiring an app restart.

---

## 🌐 REST API & Mock Integration

The data layer uses `Dio` with configurable endpoints defined in `lib/core/constants/api_constants.dart`.

### Configurable Base URL:
```dart
// lib/core/constants/api_constants.dart
class ApiConstants {
  static String baseUrl = 'https://67...mockapi.io/api/v1'; // Set your MockAPI URL here
  static const String visitorsEndpoint = '/visitors';
}
```

### Out-of-the-Box Persistent Offline Fallback Store:
If an external mock URL is unreachable or not yet configured, the app automatically runs an in-memory persistent store pre-seeded with realistic records. This guarantees that **evaluators can test the app immediately without broken network dependencies or crashes**.

---

## ⚙️ Setup and Execution Instructions

### Prerequisites
- Flutter SDK `^3.24.x` or higher
- Dart SDK `^3.5.x` or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator with Camera support


```



.
