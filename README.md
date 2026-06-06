# Landsfy Mobile App

A premium, production-ready mobile application for the **Landsfy** real estate portal, built in Flutter. This application is designed to deliver a high-performance, visually stunning experience on both Android and iOS devices, matching the core aesthetics and feature set of the [Landsfy Web Portal](http://www.landsfy.com/).

---

## 🚀 Project Overview & Status

This project implements a clean architecture and a state-of-the-art UI system to showcase real estate listings, blogs, and agent dashboards in Pakistan.

### What is Completed So Far:
1. **Core Architecture & Dependencies**:
   * Initialized project and configured [pubspec.yaml](file:///g:/landsfyapp/pubspec.yaml) with production dependencies: `flutter_bloc`, `dio`, `get_it`, `go_router`, `google_fonts`, `cached_network_image`, and `flutter_svg`.
   * Standardized typography using Google Fonts (**Outfit** for headers, **Inter** for body text).
   * Refined compiler health to be **100% warning-free**, resolving unused fields and replacing deprecated `withOpacity` APIs with modern `.withValues(alpha: ...)` calls.
2. **Branding & Theme Setup**:
   * Established a consistent brand theme in [app_theme.dart](file:///g:/landsfyapp/lib/core/theme/app_theme.dart) utilizing deep purple shades (`#4B0082`, `#6B00B6`) and premium lilac-violet tag accents. Removed all unrelated gold and blue accents to maintain high visual alignment.
3. **Splash Screen**:
   * Implemented elastic scale and smooth fade-in logo transitions on app startup before auto-routing to the Home dashboard.
4. **Home Screen Dashboard & Pinned Header Layout**:
   * **Dynamic Collapsing Search bar**: Designed a sticky header mechanic using scroll listeners. When scrolled down, the brand logo and upper buttons fade out, while a side drawer menu button slides out on the left and shrinks the search bar's width dynamically.
   * **Spacing & Spacers**: Added a safe `12px` purple spacer under the status bar when collapsed, fixed overlap conflicts between the Buy/Rent toggle and search bar, and added bottom margins to prevent overlap with the bottom nav bar.
   * **Browse Categories Section**: Features animated Category Tabs (Homes, Plots, Commercial) linked to a 2-column sub-item grid with splash ripple ink wells.
   * **Sliders & Banners**: Added horizontal Recently Viewed lists, a premium CTA banner for posting ads, horizontal Featured Property cards, and a real estate news carousel.
   * **Custom Docked Bottom Bar**: Notched BottomAppBar holding items with a custom elevated, glowing central search action button.

---

## 🎯 Development Scope

The development roadmap is divided into the following phases:

1. **Phase 1: High-Fidelity UI Prototyping** (Splash & Home Dashboard *Completed*)
   * Splash screen transitions and core navigation setup.
   * Collapsing sticky search bar physics and category grid structure.
2. **Phase 2: Details & Discovery Pages**
   * Property details view displaying comprehensive specifications (amenities, location maps, agent information, related listings).
   * Advanced search and filters overlays (integrating cities, budgets, areas).
3. **Phase 3: Web Portal API Integration**
   * Integrating core REST API endpoints from Landsfy.com.
   * Fetching dynamic listings, recently viewed items, featured properties, and blog data.
4. **Phase 4: User Panel & Posting Engine**
   * User login/registration.
   * Property upload screen (submitting pictures, filling details, pinning location on map).
   * User panel (Manage Ads, Profile settings, Favorites listing).
5. **Phase 5: Drawer Navigation Links**
   * Setting up routes for side drawer navigation: Add Property, Landsfy News portal, About Us, Contact Us, and Terms & Privacy policies.
6. **Phase 6: Final Polish & Release Management**
   * Play Store (Android) and App Store (iOS) release configuration.
   * Push notification integration.

---

## 👨‍💻 Developer Information

This mobile application is crafted and maintained by:

* **Developer & Architect**: Amanullah
* **Official Website**: [amaanullah.com](http://amaanullah.com)
* **Contact Email**: [info@amaanullah.com](mailto:info@amaanullah.com)

If you have questions about the API configuration, routing architectures, or UI layouts, feel free to reach out.

---

## 🛠️ Getting Started

To run this project locally, ensure you have Flutter SDK installed (v3.22+ recommended):

```bash
# Clone the repository
git clone https://github.com/akamaanullah/landsfy-mobile-app.git

# Navigate into the project folder
cd landsfy-mobile-app

# Get dependencies
flutter pub get

# Run on your connected device/simulator
flutter run
```
