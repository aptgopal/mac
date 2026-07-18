import 'package:flutter/material.dart';
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

  Stream<Hotel> streamHotel(String hotelId) {
    return _db
        .collection('hotels')
        .doc(hotelId)
        .snapshots()
        .map((d) => Hotel.fromMap(d.id, d.data()!));
  }

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

  Future<void> createBooking({
    required String userId,
    required String hotelId,
    required String hotelName,
    required String roomId,
    required String roomType,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    final batch = _db.batch();
    final bookingRef = _db.collection('bookings').doc();
    batch.set(bookingRef, {
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'roomType': roomType,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'status': 'confirmed',
      'createdAt': FieldValue.serverTimestamp(),
    });
    final roomRef =
        _db.collection('hotels').doc(hotelId).collection('rooms').doc(roomId);
    batch.update(roomRef, {
      'availableRooms': FieldValue.increment(-1),
    });
    await batch.commit();
  }

  Stream<List<Booking>> streamUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Booking.fromMap(d.id, d.data())).toList());
  }
}
