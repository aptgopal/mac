# UI Redesign and Localization Requirements

## Purpose
This document specifies the UI and localization behavior changes for replacing the current client app screens with the Flutter-Booking-App reference UI, and adding missing screens.

---

## Requirement: Redesigned Client Screens
The Client App SHALL replace existing screen layouts with the reference repo UI patterns.

### Scenario: Splash screen behavior
- **GIVEN** the app is launched for the first time or after a cold start
- **WHEN** the splash screen is displayed
- **THEN** the system SHALL show a Lottie animation centered on a gradient background
- **AND** display localized app text based on the saved language preference
- **AND** navigate to the language screen if no language is saved, the get-started screen if not logged in, or the main screen if already authenticated

### Scenario: Onboarding and get-started flow
- **GIVEN** a new user opens the app after selecting a language
- **WHEN** the user is not logged in
- **THEN** the system SHALL present a get-started screen with options to sign in or sign up
- **AND** provide an onboarding carousel with smooth page indicators for first-time users

### Scenario: Login and registration UI
- **GIVEN** a user taps Sign In or Sign Up
- **WHEN** the auth screen is displayed
- **THEN** the system SHALL render a centered white card with rounded corners and soft shadows
- **AND** include email, password, and social-auth placeholders consistent with the reference UI

### Scenario: Home screen layout
- **GIVEN** a user is authenticated and on the home screen
- **WHEN** the screen loads
- **THEN** the system SHALL display a horizontal image slider of featured hotels
- **AND** show a "Best Deals" section with hotel cards containing cover image, name, rating, location, and price
- **AND** maintain real-time updates from Firestore

### Scenario: Hotel details screen
- **GIVEN** a user taps a hotel card
- **WHEN** the details screen opens
- **THEN** the system SHALL show large cover imagery, hotel name, rating, location, price per night, description, amenities, and a book-now action
- **AND** preserve existing room-number and booking flows

---

## Requirement: Additional Client Screens
The Client App SHALL provide new screens present in the reference repo.

### Scenario: Language selection
- **GIVEN** no preferred language is stored
- **WHEN** the user opens the app
- **THEN** the system SHALL display a language selection screen with English and Arabic options
- **AND** save the selection for subsequent launches

### Scenario: Explore screen
- **GIVEN** the user taps the Explore tab
- **WHEN** the screen loads
- **THEN** the system SHALL show categorized hotel listings and filtering chips consistent with the reference UI

### Scenario: Filter screen
- **GIVEN** the user opens the search filter
- **WHEN** the filter screen is displayed
- **THEN** the system SHALL provide price range, star rating, property type, and amenity filters with apply/reset actions

### Scenario: Map screen
- **GIVEN** the user taps the Map tab
- **WHEN** the map screen loads
- **THEN** the system SHALL render hotel locations on a map with markers and allow tapping a marker to view hotel details

### Scenario: Trips screen
- **GIVEN** the user taps the Trips tab
- **WHEN** the trips screen loads
- **THEN** the system SHALL list upcoming and past bookings with status, dates, and hotel cover image

### Scenario: Settings screen
- **GIVEN** the user navigates to Settings
- **WHEN** the settings screen loads
- **THEN** the system SHALL list options for language, currency, notifications, and help/support links

### Scenario: Profile photo selection
- **GIVEN** the user wants to update their profile photo
- **WHEN** the user taps the profile image area
- **THEN** the system SHALL offer Gallery and Camera options
- **AND** display a preview before saving

---

## Requirement: Localization
The Client App SHALL support English and Arabic with full RTL layout switching.

### Scenario: Arabic layout
- **GIVEN** the user selects Arabic as the preferred language
- **WHEN** the locale is applied
- **THEN** the system SHALL render all text right-to-left
- **AND** use the Almarai font family for Arabic text and Poppins for English text
- **AND** mirror navigation and alignment across all screens

### Scenario: Persistent language preference
- **GIVEN** the user changes the language in Settings
- **WHEN** the change is confirmed
- **THEN** the system SHALL persist the selection locally
- **AND** restart the UI in the new locale without requiring re-authentication
