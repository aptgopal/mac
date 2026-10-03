# Client Navigation Requirements

## Purpose
This document specifies the navigation structure and routing behavior for the redesigned client app.

---

## Requirement: Bottom Navigation
The Client App SHALL provide a bottom navigation bar with four destinations: Home, Explore, Trips, and Profile.

### Scenario: Home tab
- **GIVEN** the user taps the Home destination
- **WHEN** the tab is selected
- **THEN** the system SHALL display the home screen with the search bar, featured slider, and best deals list
- **AND** keep the bottom navigation visible

### Scenario: Explore tab
- **GIVEN** the user taps the Explore destination
- **WHEN** the tab is selected
- **THEN** the system SHALL display the explore screen with categorized hotel listings and filter chips
- **AND** keep the bottom navigation visible

### Scenario: Trips tab
- **GIVEN** the user taps the Trips destination
- **WHEN** the tab is selected
- **THEN** the system SHALL display the trips screen with booking history grouped by status
- **AND** keep the bottom navigation visible

### Scenario: Profile tab
- **GIVEN** the user taps the Profile destination
- **WHEN** the tab is selected
- **THEN** the system SHALL display the profile screen with user info, settings shortcuts, and logout
- **AND** keep the bottom navigation visible

---

## Requirement: Route Transitions
The Client App SHALL use page transitions consistent with the reference repo.

### Scenario: Screen transitions
- **GIVEN** the user navigates between screens
- **WHEN** a new screen is pushed
- **THEN** the system SHALL animate the transition using slide or fade effects
- **AND** maintain a back-stack that respects the bottom navigation hierarchy
