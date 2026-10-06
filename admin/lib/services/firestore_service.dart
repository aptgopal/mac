import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------------- Hotels ----------------
  Stream<List<Hotel>> streamHotels() {
    return _db
        .collection('hotels')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Hotel.fromMap(d.id, d.data())).toList());
  }

  Future<void> addHotel(Hotel hotel) async {
    await _db.collection('hotels').add(hotel.toMap());
  }

  Future<void> updateHotel(Hotel hotel) async {
    await _db.collection('hotels').doc(hotel.id).update(hotel.toMap());
  }

  Future<void> updateHotelStatus(String hotelId, String status) async {
    await _db.collection('hotels').doc(hotelId).update({'status': status});
  }

  Future<void> deleteHotel(String hotelId) async {
    final rooms = await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .get();
    final batch = _db.batch();
    for (final r in rooms.docs) {
      batch.delete(r.reference);
    }
    batch.delete(_db.collection('hotels').doc(hotelId));
    await batch.commit();
  }

  // ---------------- Rooms ----------------
  Stream<List<Room>> streamRooms(String hotelId) {
    return _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .orderBy('roomNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Room.fromMap(d.id, hotelId, d.data()))
            .toList());
  }

  Stream<List<Room>> streamAllRooms() {
    return _db
        .collectionGroup('rooms')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                Room.fromMap(d.id, d.reference.parent.parent!.id, d.data()))
            .toList());
  }

  Future<void> addRoom(Room room) => addRooms([room]);

  Future<void> addRooms(List<Room> rooms) async {
    if (rooms.isEmpty) return;
    final batch = _db.batch();
    final hotelRef = _db.collection('hotels').doc(rooms.first.hotelId);
    for (final room in rooms) {
      final docRef = hotelRef.collection('rooms').doc();
      batch.set(docRef, room.toMap());
    }
    for (final room in rooms) {
      _setRoomType(batch, hotelRef, room);
    }
    await batch.commit();
  }

  Future<void> updateRoom(Room room) async {
    final hotelRef = _db.collection('hotels').doc(room.hotelId);
    final batch = _db.batch();
    batch.update(hotelRef.collection('rooms').doc(room.id), room.toMap());
    _setRoomType(batch, hotelRef, room);
    await batch.commit();
  }

  // Room types are stored per hotel so admins can reuse them as templates.
  void _setRoomType(
      WriteBatch batch, DocumentReference<Map<String, dynamic>> hotelRef, Room room) {
    final typeId = room.type.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    if (typeId.isEmpty) return;
    batch.set(
      hotelRef.collection('roomTypes').doc(typeId),
      {
        'name': room.type.trim(),
        'basePrice': room.price,
        'bedType': room.bedType,
        'maxOccupancy': room.maxOccupancy,
        'amenities': room.amenities,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<List<Map<String, dynamic>>> streamRoomTypes(String hotelId) {
    return _db
        .collection('hotels')
        .doc(hotelId)
        .collection('roomTypes')
        .orderBy('name')
        .snapshots()
        .map((s) => s.docs.map((d) => {'id': d.id, ...d.data()}).toList());
  }

  Future<void> updateRoomStatus(
    String roomId,
    String status, {
    DateTime? blockedUntil,
    String? hotelId,
  }) async {
    final data = <String, dynamic>{'status': status};
    if (blockedUntil != null) {
      data['blockedUntil'] = Timestamp.fromDate(blockedUntil);
    }
    if (hotelId != null) {
      await _db
          .collection('hotels')
          .doc(hotelId)
          .collection('rooms')
          .doc(roomId)
          .update(data);
    }
  }

  Future<void> blockRoom(
    String roomId,
    DateTime start,
    DateTime end,
    String reason, {
    String? hotelId,
  }) async {
    final data = <String, dynamic>{
      'status': 'BLOCKED',
      'blockedUntil': Timestamp.fromDate(end),
      'blockReason': reason,
    };
    if (hotelId != null) {
      await _db
          .collection('hotels')
          .doc(hotelId)
          .collection('rooms')
          .doc(roomId)
          .update(data);
    }
  }

  /// Holds a room back from online booking so it can be given to walk-in guests.
  Future<void> blockRoomForWalkIn(
    String hotelId,
    String roomId, {
    DateTime? until,
    String note = 'Walk-in',
  }) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .doc(roomId)
        .update({
      'status': 'BLOCKED',
      'blockType': 'WALK_IN',
      'blockReason': note,
      'blockedUntil': until != null ? Timestamp.fromDate(until) : FieldValue.delete(),
    });
  }

  Future<void> unblockRoom(String hotelId, String roomId) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .doc(roomId)
        .update({
      'status': 'AVAILABLE',
      'blockType': FieldValue.delete(),
      'blockReason': FieldValue.delete(),
      'blockedUntil': FieldValue.delete(),
    });
  }

  Future<void> deleteRoom(String hotelId, String roomId) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }

  // ---------------- Bookings ----------------
  Stream<List<Booking>> streamBookings() {
    return _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Booking>> streamFilteredBookings({
    String? status,
    DateTime? checkInDate,
    String? guestName,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('bookings');

    if (status != null && status.isNotEmpty) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map((snap) {
      var bookings = snap.docs
          .map((d) => Booking.fromMap(d.id, d.data()))
          .toList();

      if (checkInDate != null) {
        bookings = bookings.where((b) {
          return b.checkIn.year == checkInDate.year &&
              b.checkIn.month == checkInDate.month &&
              b.checkIn.day == checkInDate.day;
        }).toList();
      }

      if (guestName != null && guestName.isNotEmpty) {
        bookings = bookings
            .where((b) =>
                b.guestName.toLowerCase().contains(guestName.toLowerCase()))
            .toList();
      }

      return bookings;
    });
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }

  /// Records an offline (cash / UPI) payment received from the guest.
  Future<void> markBookingPaid(String bookingId, String method) async {
    await _db.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'PAID',
      'paymentMethod': method,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markBookingUnpaid(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'PENDING',
      'paymentMethod': FieldValue.delete(),
      'paidAt': FieldValue.delete(),
    });
  }

  // ---------------- Admin notifications ----------------
  Stream<QuerySnapshot<Map<String, dynamic>>> streamNotifications() {
    return _db
        .collection('adminNotifications')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();
  }

  /// Creates the notification only if the id doesn't exist yet, so several
  /// admin sessions can't produce duplicates.
  Future<void> createNotificationOnce(String id, Map<String, dynamic> data) async {
    final ref = _db.collection('adminNotifications').doc(id);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (snap.exists) return;
      tx.set(ref, {...data, 'read': false, 'createdAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> markNotificationsRead(Iterable<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.update(_db.collection('adminNotifications').doc(id), {'read': true});
    }
    await batch.commit();
  }

  Future<Map<String, dynamic>?> getPaymentByBookingId(String bookingId) async {
    final doc = await _db.collection('bookings').doc(bookingId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> processRefund(String bookingId, double amount) async {
    await _db.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'REFUNDED',
      'refundedAt': FieldValue.serverTimestamp(),
    });
  }
}
