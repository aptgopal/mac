## Context

The current client app uses Provider with Firebase Auth/Firestore and a custom Material 3 theme. The reference repo `moh-gomaa/Flutter-Booking-App` uses BLoC/Cubit, Dio, shared_preferences, and a custom theme system with localized strings. See `proposal.md` for motivation and `specs/` for behavioral requirements.

## Goals / Non-Goals

**Goals:**
- Replace client screen layouts and assets with the reference repo UI while preserving existing backend integration (Firebase Auth, Firestore, Razorpay).
- Add missing screens (language, onboarding, explore, filter, map, trips, settings, profile photo picker).
- Introduce localization for English and Arabic with RTL support.

**Non-Goals:**
- Migrate the client from Provider to BLoC. We will keep Provider for state management and add lightweight helpers for localization and onboarding status.
- Reimplement backend APIs. All data continues to flow through existing Firestore services and Razorpay integrations.

## Decisions

### Decision 1: Keep Provider + Add Localization Helper
- **Choice:** Retain `Provider` for auth/currency state. Add a `LocaleProvider` using `shared_preferences` and `ValueNotifier<Locale>` to drive localization without introducing BLoC.
- **Rationale:** Minimizes risk and migration effort. The reference repo's localization patterns can be adapted as plain Dart helpers.
- **Alternatives considered:** Full BLoC migration (rejected due to scope and risk).

### Decision 2: Theme Strategy
- **Choice:** Add a `LightTheme` class that centralizes colors, text styles, and card/elevated button shapes matching the reference UI. Continue using `ThemeData` extensions for backward compatibility.
- **Rationale:** The reference UI relies on specific border radii, shadows, and font families that differ from the current Material 3 defaults.
- **Alternatives considered:** Override `ThemeData` globally only (rejected because fine-grained control over individual widget styles is needed).

### Decision 3: Navigation
- **Choice:** Keep `MaterialApp` routes for auth flows. Use a `StatefulWrapper` at the home level to switch between bottom-nav tabs using `IndexedStack` or nested `Navigator`s.
- **Rationale:** Preserves existing push/pop behavior while adding tabbed navigation without a full routing overhaul.
- **Alternatives considered:** `auto_route` or `go_router` (rejected to avoid adding another dependency).

### Decision 4: New Dependencies
- **Choice:** Add `lottie`, `sizer`, `page_transition`, `smooth_page_indicator`, `cached_network_image`, `flutter_rating_bar`, `percent_indicator`, and `map_launcher` to `client/pubspec.yaml`.
- **Rationale:** These are lightweight, well-maintained, and directly required by the reference UI assets and widgets.
- **Alternatives considered:** Reimplementing animations and indicators from scratch (rejected due to time and fidelity).

### Decision 5: Assets
- **Choice:** Copy required assets (gradient backgrounds, Lottie JSON, onboarding images, fonts) from the reference repo into `client/assets/`. Reference images remain remote via `cached_network_image`.
- **Rationale:** Keeps the client self-contained for static assets while avoiding large binary blobs in git if not needed.
- **Alternatives considered:** Fetching assets from the reference repo at runtime (rejected due to offline and reliability concerns).

## Risks / Trade-offs

- **Risk:** Reference repo assets/images may not be freely redistributable.  
  → Mitigation: Use placeholders or open-source equivalents where licenses are unclear; only copy code and UI structure.
- **Risk:** Large UI diff may introduce regressions in booking/payment flows.  
  → Mitigation: Keep existing model/service layers untouched; only replace screens and widgets.
- **Risk:** Arabic RTL may break existing absolute-positioned widgets.  
  → Mitigation: Test all new and modified screens in RTL mode; use `Directionality` and `Expanded`/`Flexible` instead of fixed widths where possible.
