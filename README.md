# QuickCart (كويك كارت)

A modern, Arabic-first Flutter e-commerce app with onboarding, authentication, product catalog, and persistent cart. Built with **Clean Architecture** and **Cubit** for state management.

---

## Features

- **Onboarding** — Animated slides with local assets and completion persistence
- **Authentication** — Email/password or phone number login with OTP verification (mock; test OTP: `0000`)
- **Home** — Product grid with category tabs, search, address selector, and shimmer loading
- **Product details** — Image zoom, price, rating, description, related & recommended products, add to cart
- **Cart** — Persistent cart (local storage), quantity controls, multi-select bulk delete, related & recommended products, order summary
- **RTL** — Full right-to-left layout and Arabic UI
- **Theming** — Custom primary color, Tajawal font (Google Fonts), consistent design system

---

## Tech Stack

| Layer        | Technology                          |
| ------------ | ----------------------------------- |
| Framework    | Flutter                             |
| State        | flutter_bloc (Cubit)                |
| HTTP         | Dio                                 |
| Local storage| shared_preferences                  |
| Fonts        | google_fonts (Tajawal)              |
| Icons        | Material Icons, flutter_boxicons    |
| Architecture | Clean Architecture (domain/data/presentation) |

---

## Project Structure

```
lib/
├── core/                    # Shared utilities & config
│   ├── constants/           # API URLs, storage keys
│   └── theme/               # App theme, colors, typography
├── domain/                  # Business logic (framework-agnostic)
│   ├── entities/            # Product, CartItem, OnboardingSlide
│   └── repositories/        # Abstract contracts (Auth, Product, Cart, Onboarding)
├── data/                    # Data sources & repository implementations
│   ├── datasources/         # Remote (Dio), local (SharedPreferences)
│   ├── models/              # DTOs (e.g. ProductModel)
│   └── repositories/        # RepositoryImpl classes
├── presentation/
│   ├── cubit/               # Auth, Cart, Products state & logic
│   ├── screens/             # Onboarding, Login, OTP, Home, ProductDetails, Cart
│   └── widgets/             # Shimmer, animated page indicator, etc.
├── app.dart                 # Root widget, BlocProviders, routing
└── main.dart                # DI wiring, runApp
```

---

## Prerequisites

- **Flutter** SDK (see [pubspec.yaml](pubspec.yaml): `sdk: ^3.7.2`)
- **Dart** 3.7.2 or compatible

---

## Getting Started

### 1. Clone and install

```bash
git clone <repository-url>
cd quickcart
flutter pub get
```

### 2. Run the app

```bash
flutter run
```

Use a device or emulator with a supported platform (iOS, Android, etc.).

### 3. Test credentials

- **Email login:** any email + any password (mock; acceptance is mock-based).
- **Phone login:** any phone number → OTP screen → enter **`0000`** to verify.

---

## API

Products are loaded from the public [Fake Store API](https://fakestoreapi.com). Auth and cart are handled locally (mock auth, cart persisted with `shared_preferences`).

---

## Assets

- **Images:** `assets/images/` (e.g. onboarding slides, app logo). Ensure this folder exists and is declared under `flutter.assets` in [pubspec.yaml](pubspec.yaml).

---

## License

This project is for demonstration and learning purposes. Use and modify as needed.
