# Contact Manager App 📱

> **Technical Task Submission**  
> **Candidate / Developer:** Aman  
> **Framework:** Flutter (Channel stable 3.47.8)  
> **Language:** Dart (Null-Safe)  
> **Design Language:** Material 3 with Light & Dark Modes  

---

## 🌟 Overview

The **Contact Manager App** is a cross-platform (Web, Windows, Android, iOS) contact management application built using **Flutter** and **Dart** with strict null safety. It enables users to view, search, filter, add, edit, delete, and share contacts seamlessly with a responsive, modern interface.

### Key Highlights
- 📋 **Contact List Screen:** Displays contacts with responsive cards, category badges, star favorites, and live contact counter.
- 🔍 **Real-Time Search & Filtering:** Dynamic search across name, phone number, and email, alongside interactive category chips (`All`, `Favorites`, `Work`, `Family`, `Friends`, `General`) and multi-option sorting (A-Z, Z-A, Recently Added).
- 📇 **Add & Edit Contacts:** Interactive form with live validation for required fields, regex-verified email formatting, phone number checks, customizable avatar color picker, category assignment, and optional notes.
- 👤 **Contact Details View:** Comprehensive contact profile with Hero avatar animation, quick-action buttons (Call, SMS, Email, QR Code), and modification history timestamps.
- 🗑️ **Safe Deletion:** Deletion confirmation dialog with SnackBar **UNDO** support.
- 📱 **QR Code Generation:**
  - **Individual Contact QR Code:** Generates standardized **vCard 3.0** QR codes. Any smartphone camera can scan it to instantly import the contact into the phone's native address book!
  - **Project Submission QR Code:** Dedicated submission screen with complete technical requirements checklist, project metadata, and developer info.
- 💾 **Local Persistent Storage:** Uses `shared_preferences` so your contacts, favorites, and theme preferences persist across app restarts and browser reloads.
- 🌓 **Light & Dark Theme:** Dynamic theme switching with curated color palettes.
- 🧪 **Automated Testing:** Unit and widget tests verifying model serialization, vCard generation, validators, and app rendering.

---

## 🏗️ Project Architecture

```
my_app/
├── lib/
│   ├── main.dart                          # Application entry point with dynamic theme provider
│   ├── models/
│   │   └── contact.dart                   # Contact model with vCard, JSON & copyWith
│   ├── providers/
│   │   └── contact_provider.dart          # State management (ChangeNotifier)
│   ├── services/
│   │   └── contact_storage_service.dart   # Persistent storage & demo seed data
│   ├── screens/
│   │   ├── contact_list_screen.dart       # Main contact list & app bar
│   │   ├── contact_form_screen.dart       # Add / Edit contact form with live validation
│   │   ├── contact_detail_screen.dart     # Contact profile, quick actions & management
│   │   └── submission_qr_screen.dart      # Submission verification & QR code hub
│   ├── widgets/
│   │   ├── contact_avatar.dart            # Avatar with initials and color palette
│   │   ├── contact_tile.dart              # Contact card with category pill & favorite toggle
│   │   ├── search_bar_widget.dart         # Search input, filter chips & sort menu
│   │   ├── empty_state_widget.dart        # Empty list & no-search-results states
│   │   └── qr_dialog.dart                 # Modal for vCard and submission QR codes
│   └── utils/
│       ├── app_theme.dart                 # Material 3 light/dark themes & palettes
│       └── validators.dart                # Form validation logic
└── test/
    └── widget_test.dart                   # Unit and widget test suite
```

---

## 🚀 How to Run the Application

### 1. Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed (v3.13 or higher).
- Chrome, Edge, Windows Desktop, or an Android emulator/device connected.

### 2. Setup & Dependencies
Open a terminal in the project directory:
```bash
cd "c:/Users/amans/Desktop/contact manager app/my_app"
flutter pub get
```

### 3. Run the App
- **Run on Chrome (Web):**
  ```bash
  flutter run -d chrome
  ```
- **Run on Windows Desktop:**
  ```bash
  flutter run -d windows
  ```
- **Run on Connected Android Device:**
  ```bash
  flutter run -d android
  ```

### 4. Run Automated Tests
```bash
flutter test
```

### 5. Check Code Analysis (Linter)
```bash
flutter analyze
```

---

## 🎯 Technical Requirements Verification

| Requirement | Implementation Detail | Status |
| :--- | :--- | :---: |
| **1. Contact List Screen** | Displays Name, Phone, Email, Search Bar, Empty States | ✅ Completed |
| **2. Add & Edit Contact** | Validates required fields & email format; immediate UI update | ✅ Completed |
| **3. Contact Details** | Full profile screen, Call/SMS/Email actions, Edit & Delete | ✅ Completed |
| **4. Dart Null Safety** | Dart SDK `^3.13.7` with strict sound null safety | ✅ Completed |
| **5. Separate Contact Model** | `Contact` model with copyWith, fromMap, toMap, and vCard | ✅ Completed |
| **6. Reusable Widgets** | `ContactAvatar`, `ContactTile`, `ContactSearchBar`, `EmptyStateWidget`, `QrDialog` | ✅ Completed |
| **7. Navigation** | Declarative Material navigation between list, form, detail, and submission screens | ✅ Completed |
| **8. State Management** | `ContactProvider` (ChangeNotifier) with reactive listeners | ✅ Completed |
| **9. Local Storage** | Persistent storage using `shared_preferences` | ✅ Completed |
| **10. QR Code Generation** | vCard 3.0 Contact QR Code + Dedicated Submission QR Code Hub | ✅ Completed |

---

## 👤 Submission Details
- **Developer:** Aman
- **Project:** Contact Manager App
- **Language / Framework:** Dart / Flutter
