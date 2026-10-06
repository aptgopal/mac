import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

class AdminNotification {
  final String id;
  final String type; // NEW_BOOKING, CHECKIN_REMINDER, CHECKOUT_REMINDER
  final String title;
  final String message;
  final String bookingId;
  final bool read;
  final DateTime? createdAt;

  AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.bookingId,
    required this.read,
    this.createdAt,
  });

  factory AdminNotification.fromMap(String id, Map<String, dynamic> map) {
    return AdminNotification(
      id: id,
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      bookingId: map['bookingId'] ?? '',
      read: map['read'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}

/// Keeps admin notifications in Firestore (`adminNotifications`): new bookings
/// plus check-in / check-out reminders. Reminders are generated while the
/// admin app is open, using deterministic ids so they are created only once.
class NotificationProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirestoreService _firestore = FirestoreService();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _bookingSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _notificationSubscription;
  Timer? _reminderTimer;

  List<Booking> _bookings = [];
  List<AdminNotification> _notifications = [];
  final Set<String> _announced = {};
  bool _bookingsLoaded = false;
  bool _notificationsLoaded = false;

  GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  List<AdminNotification> get notifications => List.unmodifiable(_notifications);
  List<AdminNotification> get unread => _notifications.where((n) => !n.read).toList();
  int get unreadCount => unread.length;
  bool get hasNewNotification => unreadCount > 0;

  List<Booking> get newBookings {
    final ids = unread.where((n) => n.type == 'NEW_BOOKING').map((n) => n.bookingId).toSet();
    return _bookings.where((b) => ids.contains(b.id)).toList();
  }

  NotificationProvider() {
    _listenToBookings();
    _listenToNotifications();
    _reminderTimer = Timer.periodic(const Duration(minutes: 15), (_) => _generateReminders());
  }

  void _listenToBookings() {
    _bookingSubscription = _db
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bookings = snapshot.docs.map((d) => Booking.fromMap(d.id, d.data())).toList();

      // The first snapshot is the existing backlog; only later additions are "new".
      if (_bookingsLoaded) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.added) continue;
          final b = Booking.fromMap(change.doc.id, change.doc.data()!);
          _firestore.createNotificationOnce('booking_${b.id}', {
            'type': 'NEW_BOOKING',
            'title': 'New booking',
            'message': '${b.guestName} booked Room ${b.roomNumber} at ${b.hotelName}',
            'bookingId': b.id,
          });
        }
      }
      _bookingsLoaded = true;
      _generateReminders();
      notifyListeners();
    });
  }

  void _listenToNotifications() {
    _notificationSubscription = _firestore.streamNotifications().listen((snapshot) {
      _notifications =
          snapshot.docs.map((d) => AdminNotification.fromMap(d.id, d.data())).toList();

      if (_notificationsLoaded) {
        for (final n in _notifications.where((n) => !n.read && !_announced.contains(n.id))) {
          _showSnackBar(n);
        }
      }
      _announced.addAll(_notifications.map((n) => n.id));
      _notificationsLoaded = true;
      notifyListeners();
    });
  }

  DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  void _generateReminders() {
    final today = _day(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    for (final b in _bookings) {
      final active = b.status == 'PENDING' || b.status == 'CONFIRMED';
      final checkIn = _day(b.checkIn);
      final checkOut = _day(b.checkOut);
      final who = '${b.guestName} • Room ${b.roomNumber}, ${b.hotelName}';

      if (active && checkIn == today) {
        _remind('checkin_today_${b.id}', 'CHECKIN_REMINDER', 'Check-in today', who, b.id);
      } else if (active && checkIn == tomorrow) {
        _remind('checkin_tomorrow_${b.id}', 'CHECKIN_REMINDER', 'Check-in tomorrow', who, b.id);
      }
      if ((b.status == 'CHECKED_IN' || b.status == 'CONFIRMED') && checkOut == today) {
        _remind('checkout_today_${b.id}', 'CHECKOUT_REMINDER', 'Check-out today', who, b.id);
      }
    }
  }

  void _remind(String id, String type, String title, String message, String bookingId) {
    if (_announced.contains(id)) return;
    _firestore.createNotificationOnce(id, {
      'type': type,
      'title': title,
      'message': message,
      'bookingId': bookingId,
    });
  }

  void _showSnackBar(AdminNotification n) {
    final icon = n.type == 'NEW_BOOKING'
        ? Icons.notifications_rounded
        : Icons.access_time_rounded;
    scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${n.title}: ${n.message}',
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
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () => markRead([n.id]),
        ),
      ),
    );
  }

  Future<void> markRead(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await _firestore.markNotificationsRead(ids);
  }

  Future<void> markAsRead() => markRead(unread.map((n) => n.id));

  Future<void> clearNotifications() => markAsRead();

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    _notificationSubscription?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }
}
