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
        .orderBy('price')
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

  Future<void> addRoom(Room room) async {
    await _db
        .collection('hotels')
        .doc(room.hotelId)
        .collection('rooms')
        .add(room.toMap());
  }

  Future<void> updateRoom(Room room) async {
    await _db
        .collection('hotels')
        .doc(room.hotelId)
        .collection('rooms')
        .doc(room.id)
        .update(room.toMap());
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

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _db.collection('bookings').doc(bookingId).update({'status': status});
  }
}
