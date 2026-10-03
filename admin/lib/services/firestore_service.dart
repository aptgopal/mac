import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  Future<void> addRoom(Room room) async {
    await _db
        .collection('hotels')
        .doc(room.hotelId)
        .collection('rooms')
        .add(room.toMap());
  }

  Future<void> addRooms(List<Room> rooms) async {
    if (rooms.isEmpty) return;
    final batch = _db.batch();
    final hotelRef = _db.collection('hotels').doc(rooms.first.hotelId);
    for (final room in rooms) {
      final docRef = hotelRef.collection('rooms').doc();
      batch.set(docRef, room.toMap());
    }
    await batch.commit();
  }

  Future<void> updateRoom(Room room) async {
    await _db
        .collection('hotels')
        .doc(room.hotelId)
        .collection('rooms')
        .doc(room.id)
        .update(room.toMap());
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

  Future<void> deleteRoom(String hotelId, String roomId) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .doc(roomId)
        .delete();
  }

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
