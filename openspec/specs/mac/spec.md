# Hotel Booking Application Specification

## Overview
A Flutter-based hotel booking application with Firebase backend and Razorpay integration. Supports both **User** and **Admin** roles.

---

## 🏨 User Application

### Feature: Home Page
- **Scenario:** Display hotel details  
  - **Given** the user opens the app  
  - **Then** they should see hotel description, images, amenities, and location  
  - **And** a **Book Now** button is visible  

### Feature: Room Search & Availability
- **Scenario:** Search available rooms  
  - **Given** the user clicks **Book Now**  
  - **When** they enter dates, room type, and guest count  
  - **Then** available rooms are fetched from **Firebase Firestore**  

### Feature: Authentication
- **Scenario:** Login/Register before booking  
  - **Given** the user selects a room  
  - **Then** they must log in or register via **Firebase Authentication**  

### Feature: Room Booking & Payment
- **Scenario:** Complete booking with payment  
  - **Given** the user is logged in  
  - **When** they select room + stay duration  
  - **And** complete payment via **Razorpay Flutter SDK**  
  - **Then** booking details are saved in **Firestore**  
  - **And** confirmation email + SMS are sent via **Firebase Functions**  

### Feature: Booking Management
- **Scenario:** Manage bookings  
  - **Given** the user is logged in  
  - **Then** they can view bookings from Firestore  
  - **And** modify dates (subject to availability)  
  - **And** cancel with charges applied  
  - **And** download invoice (PDF generated via Firebase Functions)  

---

## 👑 Admin Application

### Feature: Admin Interface Design
- **Scenario:** Use the admin application across screen sizes
  - **Given** an administrator opens any admin screen
  - **Then** the interface uses Material 3 components, accessible typography, and consistent spacing
  - **And** the existing navy-and-blue identity is preserved
  - **And** primary navigation adapts between a desktop sidebar and a mobile drawer

### Feature: Admin Login
- **Scenario:** Secure login  
  - **Given** the admin opens the app  
  - **Then** they must log in via **Firebase Authentication** with admin role  

### Feature: Notifications
- **Scenario:** Browser notifications  
  - **Given** the admin is logged in via web  
  - **Then** notifications appear on the right side panel using **Firebase Cloud Messaging**  

### Feature: Dashboard
- **Scenario:** View booking & payment stats  
  - **Given** the admin is logged in  
  - **Then** they see total bookings, payments, cancellations, occupancy rate  

### Feature: Hotel Information Management
- **Scenario:** Add/modify hotel details  
  - **Given** the admin is logged in  
  - **Then** they can update hotel description, images, and amenities in Firestore  

### Feature: Room Management
- **Scenario:** Add/edit room details  
  - **Given** the admin is logged in  
  - **Then** they can add or edit room type, price, and availability in Firestore  

### Feature: Invoice Management
- **Scenario:** Share invoice  
  - **Given** a booking exists  
  - **Then** the admin can generate and share invoice via email/SMS  

---

## 🔧 Tech Stack
- **Frontend:** Flutter (Mobile + Web)  
- **Backend:** Firebase (Firestore, Authentication, Cloud Functions, Storage, FCM)  
- **Payments:** Razorpay Flutter SDK  
- **Notifications:** Firebase Cloud Messaging  
- **Email/SMS:** Firebase Functions + third-party APIs (SendGrid/Twilio)  
