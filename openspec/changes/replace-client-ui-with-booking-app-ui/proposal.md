## Why

The current client app uses a functional but minimal Booking.com-inspired UI. The reference repo `moh-gomaa/Flutter-Booking-App` provides a richer, more engaging user experience with onboarding flows, language selection, animated transitions, and polished screen layouts. Replacing the client UI with this design improves user retention and visual consistency across the booking flow.

## What Changes

- Replace existing client screens with the reference repo UI:
  - Splash screen → animated Lottie splash with language-aware text
  - Login → redesigned card-based login
  - Register → redesigned card-based registration
  - Home → slider-driven home with featured hotels and best deals
  - Search → enhanced search screen
  - Hotel details → redesigned details view
- Add new screens present in the reference repo but missing from the client:
  - Language selection
  - Get Started / Onboarding
  - Explore screen
  - Filter screen
  - Map screen
  - Trips / My Bookings redesign
  - Settings screen
  - Profile details / photo picker
- Introduce new packages and assets required by the reference UI:
  - `lottie`, `sizer`, `page_transition`, `smooth_page_indicator`, `cached_network_image`, `flutter_rating_bar`, `percent_indicator`, `map_launcher`
- Add localization support (English + Arabic) with RTL handling

## Capabilities

### Modified Capabilities
- `hotel-booking`: Update requirements to specify the redesigned UI flows, onboarding sequence, language selection, explore/filter/map/trips/settings screens, and enhanced hotel detail presentation.

### New Capabilities
- `ui-localization`: Multi-language support with language selection screen, RTL Arabic layout, and localized strings for all new screens.
- `client-navigation`: Bottom navigation and routing updates to support new screens (explore, filter, map, trips, settings) alongside existing flows.

## Impact

- Affected code: all `client/lib/screens/**` and `client/lib/main.dart`
- New assets: splash animation, onboarding images, gradient backgrounds, fonts
- New dependencies in `client/pubspec.yaml`
- Routes and navigation structure changes
- Provider state updated for language and onboarding status
