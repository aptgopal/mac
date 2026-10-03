# Hotel Booking System Specification

## Purpose
This specification defines the functional behavior for a Booking.com-style hotel reservation platform. It covers both the Client mobile/web app (hotel search, detailed room numbers, Razorpay payment processing, and general information) and the Admin management console (hotel management, room availability/reservation control, and Razorpay payment operations).

---

## Requirements

### Requirement: Hotel Search and Discovery
The Client App SHALL allow users to search for available hotels by city/location, date range, and guest count.

#### Scenario: Successful search with available results
- **GIVEN** a user specifies a target location, check-in date, check-out date, and guest count
- **WHEN** the user submits the search request
- **THEN** the system SHALL return a list of hotels in that location with room availability for the requested dates
- **AND** display key attributes for each hotel including name, cover image, rating, starting price, and distance

#### Scenario: Search with no available accommodations
- **GIVEN** a search request for dates or locations with zero available rooms
- **WHEN** the search is processed
- **THEN** the system SHALL return an empty result list
- **AND** display a helpful message suggesting alternative dates or nearby locations

---

### Requirement: Detailed Room View with Room Numbers
The Client App SHALL display detailed room information including specific physical room numbers, room types, pricing, and amenities.

#### Scenario: Viewing room inventory for a hotel
- **GIVEN** a user selects a specific hotel
- **WHEN** the user navigates to the hotel room detail section
- **THEN** the system SHALL display available rooms grouped by type (e.g., Deluxe, Executive Suite)
- **AND** list exact physical room numbers (e.g., "Room 302") along with bed type, maximum occupancy, square footage, and individual amenities

#### Scenario: Temporary room lock during checkout
- **GIVEN** a user selects a specific room number to book
- **WHEN** the user proceeds to payment checkout
- **THEN** the system SHALL lock that specific room number for 10 minutes
- **AND** prevent other users from selecting or booking that room number during the hold period

---

### Requirement: In-App Payment via Razorpay
The Client App SHALL integrate with the Razorpay SDK to process secure payments for room reservations.

#### Scenario: Initiating payment order
- **GIVEN** a user has selected a room number and filled in guest details
- **WHEN** the user taps "Proceed to Pay"
- **THEN** the system SHALL generate a unique `razorpay_order_id` on the backend
- **AND** launch the native Razorpay SDK checkout overlay with the exact amount and order ID

#### Scenario: Payment verification and booking confirmation
- **GIVEN** a user successfully completes the payment in the Razorpay overlay
- **WHEN** Razorpay returns `razorpay_payment_id` and `razorpay_signature`
- **THEN** the system SHALL verify the signature on the backend using HMAC-SHA256
- **AND** update the reservation status to `CONFIRMED`
- **AND** display a booking confirmation screen with booking ID and room number

#### Scenario: Payment failure or cancellation
- **GIVEN** a user cancels the payment or the card/UPI transaction fails
- **WHEN** Razorpay notifies the app of transaction failure
- **THEN** the system SHALL release the temporary room lock
- **AND** prompt the user to retry payment without losing entered guest information

---

### Requirement: General Platform Information
The Client App SHALL provide users with general platform information, policies, and support channels.

#### Scenario: Accessing static info and support
- **GIVEN** a user is browsing the app menu
- **WHEN** the user navigates to "General Info" or "Help & Support"
- **THEN** the system SHALL render Terms & Conditions, Privacy Policy, Cancellation & Refund Rules, FAQs, and support contact options (email/call)

---

### Requirement: Admin Hotel Property Management
The Admin App SHALL allow platform managers to create, view, update, and deactivate hotel properties.

#### Scenario: Adding a new hotel property
- **GIVEN** an authenticated admin user on the management dashboard
- **WHEN** the admin submits new hotel details including property name, address, coordinates, description, and images
- **THEN** the system SHALL persist the hotel listing
- **AND** make it available for room association

#### Scenario: Toggling hotel visibility
- **GIVEN** an existing hotel property
- **WHEN** the admin toggles the property status to `INACTIVE`
- **THEN** the system SHALL immediately hide the hotel and its rooms from client search results

---

### Requirement: Admin Room Availability and Reservation Management
The Admin App SHALL allow managers to configure physical rooms, override availability, and track reservations.

#### Scenario: Adding physical rooms with room numbers
- **GIVEN** an existing hotel property
- **WHEN** the admin creates a room entry specifying room number (e.g., "405"), room type, capacity, and nightly price
- **THEN** the system SHALL register the room under that hotel's inventory

#### Scenario: Manual availability override and room block
- **GIVEN** a room number is required for maintenance or offline walk-ins
- **WHEN** the admin sets the room's status to `BLOCKED` for a specified date range
- **THEN** the system SHALL exclude that room from client search and checkout for those dates

#### Scenario: Viewing and filtering reservations
- **GIVEN** incoming customer bookings
- **WHEN** the admin accesses the Reservation Dashboard
- **THEN** the system SHALL display reservations filterable by status (`PENDING`, `CONFIRMED`, `CHECKED_IN`, `CANCELLED`), check-in date, or guest name

---

### Requirement: Admin Payment Operations via Razorpay
The Admin App SHALL provide financial auditing, payment tracking, and refund processing through Razorpay.

#### Scenario: Payment transaction lookup
- **GIVEN** an admin reviewing financial records
- **WHEN** the admin searches by booking ID or Razorpay Payment ID
- **THEN** the system SHALL fetch and display complete payment metadata from Razorpay (amount, payment method, capture timestamp, status)

#### Scenario: Processing customer refunds
- **GIVEN** a cancelled booking eligible for a refund
- **WHEN** the admin initiates a full or partial refund from the dashboard
- **THEN** the system SHALL execute the refund API request to Razorpay
- **AND** update the transaction record with refund ID and timestamp
- **AND** notify the client of the refund status