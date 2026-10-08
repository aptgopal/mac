import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Hotel>> streamHotels() {
    return _db
        .collection('hotels')
        .where('status', isEqualTo: 'ACTIVE')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Hotel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<Hotel>> streamSearchedHotels({
    String? location,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
  }) {
    Query<Map<String, dynamic>> query = _db
        .collection('hotels')
        .where('status', isEqualTo: 'ACTIVE');

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isGreaterThanOrEqualTo: location)
                   .where('location', isLessThanOrEqualTo: '$location\uf8ff');
    }

    return query.snapshots().asyncMap((snap) async {
      final hotels = snap.docs.map((d) => Hotel.fromMap(d.id, d.data())).toList();

      if (checkIn == null || checkOut == null || guests == null) {
        return hotels;
      }

      final results = await Future.wait(hotels.map((hotel) async {
        final roomsSnapshot = await _db
            .collection('hotels')
            .doc(hotel.id)
            .collection('rooms')
            .where('status', isEqualTo: 'AVAILABLE')
            .get();

        final hasAvailableRoom = roomsSnapshot.docs.any((roomDoc) {
          final bookedUntil = roomDoc.data()['bookedUntil']?.toDate();
          if (bookedUntil != null && bookedUntil.isAfter(checkIn)) {
            return false;
          }
          return true;
        });

        return hasAvailableRoom ? hotel : null;
      }));

      return results.whereType<Hotel>().toList();
    });
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
        .orderBy('roomNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Room.fromMap(d.id, hotelId, d.data()))
            .toList());
  }

  Stream<List<Room>> streamAvailableRoomNumbers(
    String hotelId,
    String roomType,
    DateTime checkIn,
    DateTime checkOut,
  ) {
    return _db
        .collection('hotels')
        .doc(hotelId)
        .collection('rooms')
        .where('type', isEqualTo: roomType)
        .where('status', isEqualTo: 'AVAILABLE')
        .snapshots()
        .map((snap) {
          final rooms = snap.docs
              .map((d) => Room.fromMap(d.id, hotelId, d.data()))
              .toList();
          return rooms.where((room) {
            if (room.bookedUntil != null && room.bookedUntil!.isAfter(checkIn)) {
              return false;
            }
            if (room.blockedUntil != null && room.blockedUntil!.isAfter(checkIn)) {
              return false;
            }
            return true;
          }).toList();
        });
  }

  Future<void> lockRoom(String roomId, String userId, Duration duration) async {
    final lockUntil = DateTime.now().add(duration);
    await _db.collection('roomLocks').doc(roomId).set({
      'userId': userId,
      'lockedAt': FieldValue.serverTimestamp(),
      'lockedUntil': Timestamp.fromDate(lockUntil),
    }, SetOptions(merge: true));
  }

  Future<void> releaseRoomLock(String roomId) async {
    await _db.collection('roomLocks').doc(roomId).delete();
  }

  Future<String> createBookingWithPayment({
    required String userId,
    required String hotelId,
    required String hotelName,
    required String roomId,
    required String roomType,
    required String roomNumber,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String guestName,
    required String guestEmail,
    required String guestPhone,
    required double amount,
  }) async {
    final bookingRef = _db.collection('bookings').doc();
    await bookingRef.set({
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'roomType': roomType,
      'roomNumber': roomNumber,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'status': 'PENDING',
      'paymentStatus': 'PENDING',
      'amount': amount,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return bookingRef.id;
  }

  Future<void> updateBookingPayment(
    String bookingId, {
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
    String paymentStatus = 'PENDING',
  }) async {
    final data = <String, dynamic>{
      'paymentStatus': paymentStatus,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
    };
    await _db.collection('bookings').doc(bookingId).update(data);
  }

  Future<void> initiateRefund(String bookingId, double amount) async {
    await _db.collection('bookings').doc(bookingId).update({
      'paymentStatus': 'REFUNDED',
      'refundedAt': FieldValue.serverTimestamp(),
    });
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
      'roomNumber': '',
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'guests': guests,
      'guestName': '',
      'guestEmail': '',
      'guestPhone': '',
      'status': 'PENDING',
      'paymentStatus': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
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
