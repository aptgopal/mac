import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../theme/app_theme.dart';

class ManageBookingsScreen extends StatelessWidget {
  ManageBookingsScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      route: '/bookings',
      title: 'Bookings',
      body: StreamBuilder<List<Booking>>(
        stream: _firestore.streamBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const EmptyState(
              icon: Icons.book_online_outlined,
              title: 'No bookings yet',
              subtitle: 'New reservations will appear here.',
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView.separated(
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _BookingCard(b: bookings[index]),
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking b;
  const _BookingCard({required this.b});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book_online,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${b.hotelName} — ${b.roomType}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                      StatusBadge(status: b.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text(
                        '${_fmtDate(b.checkIn)} → ${_fmtDate(b.checkOut)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Text('${b.guests} guests',
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 16),
                      const Icon(Icons.badge_outlined,
                          size: 16, color: AppColors.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text('User ${b.userId}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: b.status,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                    value: 'pending', child: Text('Pending')),
                DropdownMenuItem(
                    value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(
                    value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (status) {
                if (status != null) {
                  firestore.updateBookingStatus(b.id, status);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime d) => DateFormat.yMMMd().format(d);
}
