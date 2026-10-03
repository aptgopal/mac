# UI Localization Requirements

## Purpose
This document specifies the localization behavior for the redesigned client app, including language selection, persistent storage, and RTL layout switching.

---

## Requirement: Language Selection and Persistence
The Client App SHALL allow users to select their preferred language at first launch and change it later from Settings.

### Scenario: First-launch language selection
- **GIVEN** the app has no saved language preference
- **WHEN** the splash screen completes initialization
- **THEN** the system SHALL navigate to the language selection screen
- **AND** present English and Arabic as selectable options
- **AND** save the selected language locally before proceeding

### Scenario: Changing language from Settings
- **GIVEN** the user is on the Settings screen
- **WHEN** the user taps the Language option
- **THEN** the system SHALL open the language selection screen
- **AND** upon confirmation, update the app locale and restart the UI tree in the new language

---

## Requirement: RTL Layout Support
The Client App SHALL render Arabic text and layouts in right-to-left direction.

### Scenario: Arabic text rendering
- **GIVEN** the current locale is Arabic
- **WHEN** any screen is built
- **THEN** the system SHALL use the Almarai font family for body and headings
- **AND** align text, icons, and navigation elements to the right
- **AND** mirror the reading order of lists and cards

### Scenario: English text rendering
- **GIVEN** the current locale is English
- **WHEN** any screen is built
- **THEN** the system SHALL use the Poppins font family for body and headings
- **AND** align text, icons, and navigation elements to the left
