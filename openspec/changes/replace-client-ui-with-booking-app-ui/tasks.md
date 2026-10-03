## 1. Setup and Dependencies

- [x] 1.1 Add new dependencies to `client/pubspec.yaml` (`lottie`, `sizer`, `page_transition`, `smooth_page_indicator`, `cached_network_image`, `flutter_rating_bar`, `percent_indicator`, `map_launcher`)
- [x] 1.2 Create `client/assets/` subdirectories (`images`, `fonts`, `lottie`) and add required font files and Lottie JSON
- [x] 1.3 Add asset declarations to `client/pubspec.yaml`
- [x] 1.4 Create `client/lib/core/localization/app_localization.dart` and AR/EN JSON files under `assets/lang/`
- [x] 1.5 Create `client/lib/providers/locale_provider.dart` for language state and persistence

## 2. Theme and Navigation Foundation

- [x] 2.1 Create `client/lib/core/theme/app_theme.dart` with reference UI colors, fonts, and widget themes
- [x] 2.2 Update `client/lib/main.dart` to use the new theme, localization delegates, and locale provider
- [x] 2.3 Add bottom navigation routes and tab-switching logic in `client/lib/screens/home/` or a new main shell

## 3. New Onboarding and Auth Screens

- [x] 3.1 Replace `client/lib/screens/splash_screen.dart` with Lottie-based splash and language-aware routing
- [x] 3.2 Create `client/lib/screens/language/language_screen.dart`
- [x] 3.3 Create `client/lib/screens/onboarding/onboarding_screen.dart` with smooth page indicator
- [x] 3.4 Create `client/lib/screens/get_started/get_started_screen.dart`
- [x] 3.5 Replace `client/lib/screens/auth/login_screen.dart` with redesigned card-based UI
- [x] 3.6 Replace `client/lib/screens/auth/register_screen.dart` with redesigned card-based UI

## 4. Home, Search, and Hotel Details

- [x] 4.1 Replace `client/lib/screens/home/home_screen.dart` with slider + best deals layout
- [x] 4.2 Replace `client/lib/screens/home/search_screen.dart` with enhanced search UI
- [x] 4.3 Replace `client/lib/screens/hotel/hotel_detail_screen.dart` with redesigned details view

## 5. Additional Client Screens

- [x] 5.1 Create `client/lib/screens/explore/explore_screen.dart`
- [x] 5.2 Create `client/lib/screens/filter/filter_screen.dart`
- [x] 5.3 Create `client/lib/screens/map/map_screen.dart`
- [x] 5.4 Create `client/lib/screens/trips/trips_screen.dart`
- [x] 5.5 Replace `client/lib/screens/profile/profile_screen.dart` with redesigned profile UI
- [x] 5.6 Create `client/lib/screens/settings/settings_screen.dart`
- [x] 5.7 Add profile photo picker flow (`Gallery` / `Camera`) to profile

## 6. RTL and Polish

- [x] 6.1 Verify Arabic RTL layout across all new and replaced screens
- [x] 6.2 Apply page transitions and animation tweaks for consistency
- [x] 6.3 Run `flutter analyze` and fix lint issues in modified files
