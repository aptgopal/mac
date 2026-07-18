import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/room.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';
import '../widgets/common.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return AdminScaffold(
      route: '/dashboard',
      title: 'Dashboard',
      actions: const [],
      body: PagePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Admin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Here is an overview of your property portfolio.',
                style: TextStyle(color: AppColors.muted, fontSize: 14)),
            const SizedBox(height: 24),
            _StatsGrid(firestore: firestore),
            const SizedBox(height: 32),
            const SectionTitle(
                title: 'Quick actions',
                subtitle: 'Jump straight into managing your inventory.'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _QuickLink(
                  icon: Icons.hotel,
                  label: 'Manage Hotels',
                  route: '/hotels',
                  color: AppColors.primary,
                ),
                _QuickLink(
                  icon: Icons.meeting_room,
                  label: 'Rooms & Availability',
                  route: '/rooms',
                  color: AppColors.primaryLight,
                ),
                _QuickLink(
                  icon: Icons.book_online,
                  label: 'Bookings',
                  route: '/bookings',
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final FirestoreService firestore;
  const _StatsGrid({required this.firestore});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = constraints.maxWidth > 900
            ? 4
            : (constraints.maxWidth > 600 ? 2 : 1);
        return GridView.count(
          crossAxisCount: cross,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.6,
          children: [
            StreamBuilder<List<Hotel>>(
              stream: firestore.streamHotels(),
              builder: (_, s) => StatTile(
                icon: Icons.hotel,
                label: 'Hotels',
                value: '${s.data?.length ?? 0}',
                color: AppColors.primary,
                onTap: () => Navigator.of(context).pushNamed('/hotels'),
              ),
            ),
            StreamBuilder<List<Room>>(
              stream: firestore.streamAllRooms(),
              builder: (_, s) {
                final rooms = s.data ?? [];
                final available =
                    rooms.fold<int>(0, (sum, r) => sum + r.availableRooms);
                return StatTile(
                  icon: Icons.meeting_room,
                  label: 'Rooms available',
                  value: '$available',
                  color: AppColors.primaryLight,
                );
              },
            ),
            StreamBuilder<List<Booking>>(
              stream: firestore.streamBookings(),
              builder: (_, s) {
                final confirmed = (s.data ?? [])
                    .where((b) => b.status == 'confirmed')
                    .length;
                return StatTile(
                  icon: Icons.check_circle,
                  label: 'Confirmed bookings',
                  value: '$confirmed',
                  color: AppColors.success,
                );
              },
            ),
            StreamBuilder<List<Booking>>(
              stream: firestore.streamBookings(),
              builder: (_, s) {
                final pending = (s.data ?? [])
                    .where((b) => b.status == 'pending')
                    .length;
                return StatTile(
                  icon: Icons.pending_actions,
                  label: 'Pending bookings',
                  value: '$pending',
                  color: AppColors.warning,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _QuickLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final Color color;
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: const Border.fromBorderSide(
              BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
