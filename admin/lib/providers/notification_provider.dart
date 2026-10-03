import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSubscription;
  final List<Booking> _newBookings = [];
  int _previousBookingCount = 0;
  bool _hasNewNotification = false;
  GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  List<Booking> get newBookings => List.unmodifiable(_newBookings);
  bool get hasNewNotification => _hasNewNotification;
  int get unreadCount => _newBookings.length;

  NotificationProvider() {
    _listenToBookings();
  }

  void _listenToBookings() {
    _bookingSubscription = _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final currentCount = snapshot.docs.length;
      
      if (currentCount > _previousBookingCount && _previousBookingCount > 0) {
        final newDocs = snapshot.docs.take(currentCount - _previousBookingCount);
        for (final doc in newDocs) {
          final booking = Booking.fromMap(doc.id, doc.data());
          _newBookings.add(booking);
        }
        _hasNewNotification = true;
        _showNotification();
      }
      
      _previousBookingCount = currentCount;
      notifyListeners();
    });
  }

  void _showNotification() {
    if (_newBookings.isNotEmpty) {
      final latestBooking = _newBookings.first;
      final message = 'New booking from ${latestBooking.guestName} for Room ${latestBooking.roomNumber}';
      
      scaffoldKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF003580),
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          action: SnackBarAction(
            label: 'VIEW',
            textColor: Colors.white,
            onPressed: () {
              markAsRead();
            },
          ),
        ),
      );
    }
  }

  void markAsRead() {
    _newBookings.clear();
    _hasNewNotification = false;
    notifyListeners();
  }

  void clearNotifications() {
    _newBookings.clear();
    _hasNewNotification = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}
