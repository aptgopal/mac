# Hotel / Lodge Booking — Flutter + Firebase

Two Flutter apps sharing the same Firebase backend (real-time via Firestore):

| App | Path | Target | Purpose |
|-----|------|--------|---------|
| **Client** | `client/` | Android + Web | Guests: register/login, browse hotels & rooms, book, view own bookings |
| **Admin** | `admin/` | Windows (desktop) | Staff: login only (no register), manage hotels/rooms/availability/bookings |

Data lives in **Firestore**. All reads use `snapshots()` (real-time streams), so when the
admin updates room availability it appears instantly in the client app, and bookings made by
clients appear instantly in the admin app.

---

## 1. Install prerequisites (one time)

Run these from an **Administrator** PowerShell on Windows.

1. **Git** — https://git-scm.com/download/win (required by Flutter)
2. **Flutter SDK** — https://docs.flutter.dev/get-started/install/windows
   - Unzip, add `flutter\bin` to `PATH`.
   - Enable desktop + accept licenses:
     ```
     flutter config --enable-windows-desktop
     flutter doctor --android-licenses
     ```
    3. **Android Studio** (for the client Android build) — install with "Android SDK" + "Android SDK Command-line Tools".
    Create an emulator or plug in a device.
    4. **Google Chrome** (for the client Web build) — used by `flutter run -d chrome`. Edge also works.
4. **Visual Studio 2022** (for the Windows admin app) — "Desktop development with C++" workload.
5. **Firebase CLI** — https://firebase.google.com/docs/cli (needs Node.js)
   ```
   npm install -g firebase-tools
   firebase login
   ```
6. **FlutterFire CLI**
   ```
   dart pub global activate flutterfire_cli
   ```

Verify:
```
flutter doctor
```
Everything except maybe "Connected device" for iOS should be green.

---

## 2. Create the Firebase project (one time)

1. Go to https://console.firebase.google.com → **Add project** → name it (e.g. `lodge-booking`).
2. **Build → Authentication → Sign-in method → Email/Password → Enable.**
3. **Build → Firestore Database → Create database → Start in test mode** (you'll tighten rules later).
4. **Project settings (gear) → General → Your apps → Add app:**
    - Add an **Android app** (package name e.g. `com.example.lodgebooking`, download `google-services.json` into `client/android/app/`).
    - Add a **Web app** (used by both the client's web build and the Windows admin app's Firebase config).

---

## 3. Wire each app to Firebase

From the repo root:

```powershell
# Client (Android + Web)
cd client
flutter create . --platforms=android,web
flutterfire configure            # picks Android + Web, writes lib/firebase_options.dart

# Admin (Windows)
cd ../admin
flutter create . --platforms=windows
flutterfire configure            # picks Web + Windows, writes lib/firebase_options.dart
```

`flutterfire configure` overwrites the placeholder `lib/firebase_options.dart` with your real keys.

---

## 4. Create the admin account

The admin app has **no register screen** — admin accounts are created manually:

1. In Firebase **Authentication**, click **Add user**, set email + password (e.g. `admin@lodge.app`).
2. In **Firestore**, create document `users/<uid>` with fields:
   ```
   email: "admin@lodge.app"
   role:  "admin"
   createdAt: (server timestamp)
   ```
   (Get `<uid>` from the Authentication user list.)
3. Client users are created automatically on register and get `role: "user"`.

---

## 5. Firestore security rules (paste in Firestore → Rules)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() { return request.auth != null; }
    function isAdmin() {
      return isSignedIn() &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /users/{uid} {
      allow read: if isSignedIn();
      allow write: if isSignedIn() && request.auth.uid == uid;
    }
    match /hotels/{hotelId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
      match /rooms/{roomId} {
        allow read: if isSignedIn();
        allow write: if isAdmin();
      }
    }
    match /bookings/{bookingId} {
      allow read: if isSignedIn() &&
        (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if isSignedIn() &&
        request.resource.data.userId == request.auth.uid;
      allow update, delete: if isAdmin();
    }
  }
}
```

---

## 6. Run

```powershell
# Client on Android (device / emulator)
cd client && flutter run

# Client on Web (Chrome)
cd client && flutter run -d chrome

# Admin on Windows
cd admin  && flutter run -d windows
```

---

## Data model

```
users/{uid}                { email, role: "user"|"admin", createdAt }
hotels/{hotelId}           { name, location, description, imageUrl, pricePerNight, createdAt }
hotels/{hotelId}/rooms/{roomId}
                           { type, price, totalRooms, availableRooms, amenities[], createdAt }
bookings/{bookingId}       { userId, hotelId, hotelName, roomId, roomType,
                             checkIn, checkOut, guests, status, createdAt }
```

Real-time: every list screen uses `FirestoreService.streamX()` which calls `.snapshots()`,
so availability/booking changes sync both ways automatically.

## Next steps (future)
- Date-range availability (booking calendar) instead of a single inventory count.
- Images upload (Firebase Storage) instead of image URLs.
- Payments, search/filter, push notifications, multi-language.
