# 🏠 Landsfy Mobile App

A premium, production-ready **Flutter** mobile application for the [Landsfy](http://www.landsfy.com/) real estate portal — Pakistan's property discovery platform. Built with a fully modular clean architecture, delivering a visually stunning experience on both Android and iOS.

---

## ✨ Feature Overview

| Screen | Status | Highlights |
|---|---|---|
| Splash Screen | ✅ Done | Elastic scale + fade-in logo animation |
| Home Dashboard | ✅ Done | Collapsing sticky header, category grid, featured listings, blogs |
| Properties Discovery | ✅ Done | Filter panel, search bar, 2-column grid layout |
| Property Details | ✅ Done | Image carousel, specs, agent contact, related listings |
| Search Screen | ✅ Done | Full-featured search with live results + filters |
| Favorites Screen | ✅ Done | 2-column saved properties grid with compact cards |
| Profile / Dashboard | ✅ Done | Role-based dashboard (Buyer / Seller / Agent / Agency / Admin) |
| Login Screen | ✅ Done | Email + password, Google sign-in option |
| Sign Up Screen | ✅ Done | Full registration form, Google sign-up option |

---

## 🏗️ Architecture & Project Structure

The project follows a **feature-first modular architecture** with clean separation of UI, logic, and shared core concerns.

```
lib/
├── core/
│   ├── router/           # go_router route definitions
│   └── theme/            # AppTheme, AppColors, typography tokens
├── features/
│   ├── splash/           # Splash screen with animated logo
│   ├── home/             # Main shell: collapsing AppBar, bottom nav, home feed
│   ├── properties/       # Properties listing: search bar, filters, 2-col grid
│   ├── property_details/ # Detail view: carousel, specs, agent info, related
│   ├── search/           # Full search screen with live filtering
│   ├── favorites/        # Saved properties 2-column grid
│   └── profile/
│       ├── login_screen.dart       # Login with email or Google
│       ├── signup_screen.dart      # Sign up with email or Google
│       ├── profile_screen.dart     # Auth-gate: shows login or dashboard
│       └── widgets/
│           ├── role_dashboard_view.dart  # Role-based stats + actions
│           ├── stat_card.dart            # Metric card widget
│           └── profile_menu_tile.dart    # Tappable settings row
└── main.dart
```

---

## 📱 Screen Details

### 🏠 Home Dashboard
- **Collapsing SliverAppBar**: Dynamic sticky header with buy/rent toggle and search bar that morphs as you scroll. Logo fades out and a slide-out drawer button appears.
- **Category Grid**: Tab pills (Homes, Plots, Commercial, All Purpose) linked to a sub-pill filter row (Popular, Type, Area Size), rendering an animated 2-column icon grid.
- **Recently Viewed**: Horizontal property card slider.
- **CTA Banner**: "Post Your Ad Free" promotional banner.
- **Featured Properties**: Premium property cards with badge types (Diamond, Platinum, Featured).
- **Real Estate Blog Feed**: Horizontally scrollable news cards with category tags.
- **Custom Docked Bottom Bar**: Notched BottomAppBar with a glowing elevated central Search button.

### 🔍 Properties Screen
- Collapsible filter panel with sort/filter chips.
- In-screen search bar.
- 2-column compact property card grid.
- Purpose toggle (Buy / Rent).

### 📋 Property Details Screen
- Full-width image carousel with page indicators.
- Spec row: beds, baths, area.
- Agent contact section.
- Related Properties horizontal slider with deep-link navigation.

### 🔎 Search Screen
- Live search input with suggestions.
- Filter chips for property type, purpose, city.
- Grid results view with compact cards.

### ❤️ Favorites Screen
- 2-column responsive grid of saved properties.
- Compact cards with badge overlays (Diamond / Platinum / Featured), purpose tag, and solid heart icon.
- Empty state illustration.

### 👤 Profile & Dashboard
Authentication is managed by `ProfileScreen`, which gate-keeps between:

- **Login Screen**: Email/password form, forgot password, Google continue button, and toggle to Sign Up.
- **Sign Up Screen**: Full name, email, phone, password fields, terms checkbox, Google sign-up, and toggle to Login.
- **Role-Based Dashboard** (post-login): Role selector chips at the top to switch between:

| Role | Stats Shown | Panel Actions |
|---|---|---|
| **Buyer** | Saved Listings, Alerts, Agents Contacted, Viewed History | Saved Searches, Alerts, Shortlists, History, Contacts |
| **Seller** | Listed Properties, Views, Inquiries, Closed Deals | My Properties, Post New, Buyer Leads, Inquiries, Analytics |
| **Agent** | Active Clients, Listings, Leads, Est. Commission | Listed Properties, Client Leads, Commission Tracker, Agency Profile, Subscription |
| **Agency Owner** | Active Agents, Agency Listings, Total Leads, Revenue | Manage Agents, Listings, Analytics, Subscription, Settings |
| **Admin** | Total Users, Pending Approvals, Active Listings, Reports | Moderation Queue, User Mgmt, Property Verification, Config, Audit Logs |

---

## 🎨 Design System

- **Primary Color**: Deep Violet `#4B0082` / `#6B00B6`
- **Accent**: Warm Lilac/Gold tag palette
- **Typography**: `Outfit` (headings/display) + `Inter` (body/labels) via Google Fonts
- **Cards**: Rounded corners (14–18px), subtle shadow, white surface
- **Animations**: `AnimatedContainer`, `BouncingScrollPhysics`, elastic splash transitions
- **Badges**: Diamond 💎 / Platinum ✨ / Featured ⭐ / Regular

---

## 🔧 Tech Stack & Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management (BLoC pattern) |
| `go_router` | Declarative navigation & deep linking |
| `dio` | HTTP client for REST API |
| `get_it` | Dependency injection container |
| `google_fonts` | Outfit + Inter typography |
| `cached_network_image` | Efficient network image caching |
| `flutter_svg` | SVG icon rendering |

---

## 🗺️ Development Roadmap

- [x] **Phase 1** — Splash & Home Dashboard (collapsing header, category grid, featured listings)
- [x] **Phase 2** — Properties Discovery, Property Details, Search Screen
- [x] **Phase 3** — Favorites (2-col grid), Profile Dashboard (5 roles), Login & Sign Up screens
- [ ] **Phase 4** — Landsfy REST API integration (live listings, blogs, featured data)
- [ ] **Phase 5** — Property Upload Engine (photos, specs, map pin)
- [ ] **Phase 6** — Push Notifications, Drawer nav links (About, Contact, T&C)
- [ ] **Phase 7** — Play Store (Android) & App Store (iOS) release build & configuration

---

## 🚀 Getting Started

Ensure you have **Flutter SDK v3.22+** installed.

```bash
# Clone the repository
git clone https://github.com/akamaanullah/landsfy-mobile-app.git

# Navigate into the project folder
cd landsfy-mobile-app

# Install dependencies
flutter pub get

# Run on your connected device or simulator
flutter run
```

> **Note**: This is currently a UI prototype using static mock data. API integration is planned for Phase 4.

---

## 👨‍💻 Developer Information

Crafted and maintained by:

- **Developer & Architect**: Amanullah
- **Website**: [amaanullah.com](http://amaanullah.com)
- **Email**: [info@amaanullah.com](mailto:info@amaanullah.com)

For questions on API configuration, routing architecture, or UI design decisions, feel free to reach out.
