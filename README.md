# 🚀 MahekSync

> **Premium Editorial Management Dashboard**
>
> A sophisticated, full-featured SaaS platform built with Flutter Web for managing devices, subscriptions, purchases, reminders, and more — all designed with editorial precision and kinetic velocity.

---

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.27+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.6+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-🔥-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![GetX](https://img.shields.io/badge/GetX-4.6+-8A2BE2?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20iOS%20%7C%20Android-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-Proprietary-red?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active%20Development-brightgreen?style=for-the-badge)

</div>

---

## ✨ Features

<details open>
<summary><b>📱 Device Management</b></summary>
<br>

- **CRUD Operations** — Add, edit, view, and delete devices with full lifecycle management
- **Image Gallery** — Multi-image upload with ImageKit integration and thumbnail navigation
- **Warranty Tracking** — Visual progress indicators for warranty periods with smart alerts
- **Dynamic Categories** — Real-time category and payment method dropdowns from Firestore
- **Advanced Filtering** — Search, filter by category, payment method, condition, and price range
- **Grid/List Views** — Toggle between responsive grid and list layouts
- **Portfolio Summary** — Total value, item count, and category-wise breakdown

</details>

<details open>
<summary><b>💳 Subscription Manager</b></summary>
<br>

- **Full CRUD** — Create, read, update, and delete subscriptions
- **Smart Tracking** — Monitor active, expiring, and expired subscriptions
- **Liquid Progress** — Animated water-bubble progress indicator with cold-drink effect
- **Renewal System** — Custom date picker for subscription renewal
- **Cost Analysis** — Monthly/yearly cost projections and portfolio summaries
- **Multi-filter** — Filter by category, status, date range, and payment method
- **Grouping & Sorting** — Group by category/status, sort by price, expiry, or name
- **Visual Alerts** — Color-coded urgency indicators (critical ≤3 days, soon ≤7 days)

</details>

<details open>
<summary><b>🛒 Purchase Management</b></summary>
<br>

- **Full Inventory** — Track all purchases with detailed asset information
- **Image Gallery** — Full-width hero image with thumbnail navigation and zoom
- **Status Tracking** — Delivered, In Transit, Pre-Order with color-coded badges
- **Financial Data** — Price, payment method, purchase/warranty dates
- **Logistics** — Store location, size, units, and condition tracking
- **Quick Stats** — Portfolio value, item count, and category distribution

</details>

<details open>
<summary><b>🔔 Smart Reminders</b></summary>
<br>

- **Priority Levels** — HIGH, MEDIUM, LOW with visual importance indicators
- **Global Toasts** — Glassmorphism reminder toasts appear every 10s across all pages
- **Active Toggle** — Enable/disable reminders with real-time switch
- **Date Tracking** — Created and expiry dates with "days remaining" badges
- **Icon Upload** — Custom icons for each reminder with ImageKit storage
- **Dashboard Integration** — Full management section in the sidebar

</details>

<details open>
<summary><b>🏷️ Category Management</b></summary>
<br>

- **Visual Anchors** — Upload custom icons for each category
- **Item Tracking** — Auto-count of items per category
- **Grid/List Views** — Responsive layout with toggle
- **Quick Edit** — Inline editing with form validation
- **Search & Filter** — Real-time search across all categories

</details>

<details open>
<summary><b>💎 Premium Features</b></summary>
<br>

- **🎨 Animated Splash Screen** — Custom Lottie animations with progress tracking
- **🌙 Dark/Light Themes** — Full theme switching with persistence
- **📱 Responsive Design** — Adapted for mobile, tablet, laptop, and desktop (up to 32" monitors)
- **🪟 Glassmorphism UI** — Frosted glass effects with backdrop blur
- **🖱️ Hover Effects** — Smooth cursor interactions and micro-animations
- **🔐 Authentication** — Firebase Auth with email/password and Google sign-in
- **👤 Profile Management** — Admin profile with Lottie avatar ring
- **📊 Dashboard Home** — Welcome banner, quick stats, and recent activity

</details>

---

## 🏗️ Architecture

```
MahekSync/
├── lib/
│   ├── app/
│   │   ├── modules/
│   │   │   ├── add_new_devices/      # Device registration
│   │   │   ├── admin_profile/        # Admin profile view
│   │   │   ├── auth/                 # Authentication (login/signup)
│   │   │   ├── categories/           # Category management
│   │   │   ├── dashboard/            # Main dashboard shell
│   │   │   ├── my_devices/           # Device inventory list
│   │   │   ├── my_purchases/         # Purchase management
│   │   │   ├── payment_methods/      # Payment method manager
│   │   │   ├── reminder/             # Reminder list & management
│   │   │   ├── settings/             # App settings
│   │   │   ├── splash_screen/        # Animated splash
│   │   │   ├── subscription/         # Subscription tracking
│   │   │   └── view_devices/         # Device detail view
│   │   ├── models/                   # Data models
│   │   ├── services/                 # API services (ImageKit, Firebase)
│   │   ├── utils/                    # Utilities & helpers
│   │   ├── widgets/                  # Reusable widgets
│   │   └── routes/                   # App routing
│   └── main.dart                     # Entry point
├── assets/
│   ├── animation/                    # Lottie animations
│   ├── icons/                        # SVG icons
│   └── images/                       # Static images
└── pubspec.yaml                      # Dependencies
```

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.27+** | Cross-platform UI framework |
| **Dart 3.6+** | Programming language |
| **GetX** | State management, routing, DI |
| **Firebase** | Backend (Auth, Firestore, Storage) |
| **Cloud Firestore** | Real-time NoSQL database |
| **Firebase Auth** | User authentication |
| **ImageKit** | Image upload and CDN delivery |
| **Lottie** | Vector animations |
| **Provider** | Theme state management |
| **Cached Network Image** | Image caching |
| **Flutter SVG** | SVG rendering |
| **HTTP** | API communication |
| **UUID** | Unique ID generation |
| **Intl** | Date formatting |
| **Image Picker** | Device image selection |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.27+
- Dart SDK 3.6+
- Firebase project with Firestore enabled
- ImageKit account (for image uploads)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/maheksync.git

# Navigate to project directory
cd maheksync

# Install dependencies
flutter pub get

# Configure Firebase
# 1. Create a Firebase project
# 2. Add your google-services.json / GoogleService-Info.plist
# 3. Enable Authentication and Firestore

# Configure ImageKit
# Update the public/private keys in:
# lib/app/services/imagekit_api.dart

# Run the app
flutter run -d chrome  # For web
flutter run -d ios     # For iOS
flutter run -d android # For Android
```

### Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password + Google)
3. Enable **Cloud Firestore**
4. Add your Flutter app to the Firebase project
5. Download and place configuration files
6. Update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🎨 Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#5D54F2` | Brand color, buttons, highlights |
| Success | `#008E38` | Active status, success messages |
| Danger | `#E7000B` | Delete actions, expired status |
| Warning | `#B28C00` | Expiring soon, pending status |
| Dark BG | `#1A1A1A` | Primary background (dark mode) |
| Surface | `#2A2A2A` | Card backgrounds |
| Text Primary | `#FAFAFA` | Primary text (dark mode) |

### Responsive Breakpoints

| Device | Width | Columns |
|--------|-------|---------|
| Mobile | < 600px | 1 |
| Tablet | 600-900px | 2 |
| Small Laptop | 900-1200px | 2 |
| Laptop | 1200-1440px | 3 |
| Desktop | 1440-1920px | 3-4 |
| Large Desktop | > 1920px | 4+ |

---

## 📦 Core Modules

### 🔄 State Management (GetX)

```dart
class SubscriptionController extends GetxController {
  final subscriptions = <SubscriptionModel>[].obs;
  final isLoading = true.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadSubscriptions();
  }
}
```

### 🔥 Firestore Integration

```dart
static Stream<List<SubscriptionModel>> getUserSubscriptions(String ownerId) {
  return _firestore
      .collection('subscriptions')
      .where('ownerId', isEqualTo: ownerId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => SubscriptionModel.fromJson(doc.data()))
          .toList());
}
```

### 🖼️ ImageKit Upload

```dart
static Future<String?> uploadImage({
  required XFile imageFile,
  required String folderName,
}) async {
  // Upload to ImageKit CDN
  // Returns public URL
}
```

---

## 🎯 Key Features Deep Dive

### 💧 Water Bubble Progress

Animated liquid-fill progress indicator with:
- Cold drink wave effect
- Multiple sine waves
- Random color assignment per instance
- Smooth 0→target animation over configurable duration
- Bubbles and glass reflection effects

### 🔔 Global Reminder Toasts

- Polls Firestore every 10 seconds
- Shows glassmorphism overlay on any page
- Auto-rotates through all active reminders
- Slide-up animation with progress bar
- Manual dismiss with close button

### 📊 Smart Subscription Tracking

- Auto-calculates monthly/yearly costs
- Detects critical (≤3 days) and soon (≤7 days) expirations
- Color-coded status indicators
- Group by category or status
- Sort by name, price, or expiry date

---

## 🧪 Testing

```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/

# Check code quality
flutter analyze

# Format code
dart format .
```

---

## 📈 Performance

- **Lazy Loading** — Controllers initialized on demand
- **Image Caching** — CachedNetworkImage for optimal loading
- **Stream Builders** — Real-time updates without polling
- **Efficient Rebuilds** — GetX reactive state management
- **Code Splitting** — Modular architecture for tree shaking

---

## 🔒 Security

- Firebase Authentication for user management
- Firestore security rules
- ImageKit private key authentication
- Secure password handling
- Session management with "Remember Me"

---

## 🗺️ Roadmap

### v1.0 (Current)
- [x] Device Management
- [x] Subscription Tracking
- [x] Purchase Management
- [x] Category Management
- [x] Payment Methods
- [x] Reminders System
- [x] Dark/Light Theme
- [x] Responsive Design

### v1.1 (Planned)
- [ ] Export to CSV/PDF
- [ ] Email notifications
- [ ] Push notifications
- [ ] Team collaboration
- [ ] Advanced analytics dashboard
- [ ] Bulk import/export
- [ ] API rate limiting
- [ ] Offline support

### v1.2 (Future)
- [ ] AI-powered insights
- [ ] Voice commands
- [ ] Desktop app (Electron)
- [ ] Plugin marketplace
- [ ] White-label support
- [ ] Multi-language (i18n)

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Convention
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` UI/UX changes
- `refactor:` Code restructuring
- `perf:` Performance improvements
- `test:` Testing
- `chore:` Maintenance

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 👨‍💻 Author

<div align="center">

### Mahek Kevat

**Full-Stack Flutter Developer & UI/UX Designer**

[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/mahekjkevat)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/mahekjkevat)
[![Email](https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:mahekjkevat@gmail.com)

</div>

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev) - UI toolkit
- [GetX](https://pub.dev/packages/get) - State management
- [Firebase](https://firebase.google.com) - Backend services
- [ImageKit](https://imagekit.io) - Image CDN
- [Lottie](https://airbnb.design/lottie/) - Animations
- All the amazing open-source packages that made this possible

---

<div align="center">

### ⭐ Star this repo if you find it useful!

**Made with ❤️ and Flutter**

<img src="https://flutter.dev/images/flutter-logo.svg" width="30" alt="Flutter Logo"/>

</div>