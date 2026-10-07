import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/booking.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  Color _statusColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF00C853).withOpacity(0.12);
      case 'PENDING':
        return const Color(0xFFFFC107).withOpacity(0.12);
      case 'CANCELLED':
        return const Color(0xFFD32F2F).withOpacity(0.12);
      case 'CHECKED_IN':
        return const Color(0xFF0099FF).withOpacity(0.12);
      default:
        return Colors.grey.withOpacity(0.12);
    }
  }

  Color _statusTextColor(String status, ThemeData theme) {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return const Color(0xFF00C853);
      case 'PENDING':
        return const Color(0xFFE65100);
      case 'CANCELLED':
        return const Color(0xFFD32F2F);
      case 'CHECKED_IN':
        return const Color(0xFF0099FF);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final firestore = FirestoreService();
    final fmt = DateFormat.yMMMd();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF003580), Color(0xFF0066CC)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'My Bookings',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (auth.user == null)
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.bookmark_rounded,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Sign in to view your bookings',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your reservations will appear here after you sign in.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/login'),
                        child: const Text('Sign In'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pushReplacementNamed('/home'),
                        child: const Text('Browse Hotels'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            StreamBuilder<List<Booking>>(
              stream: firestore.streamUserBookings(auth.user!.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: Color(0xFFD32F2F),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Could not load your bookings.',
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check that you are signed in and Firestore rules '
                              'allow you to read bookings belonging to your account.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            SelectableText(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  );
                }
                final bookings = snapshot.data!;
                if (bookings.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Icon(Icons.bookmark_rounded,
                                size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'You have no bookings yet.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed('/home'),
                              icon: const Icon(Icons.search_rounded),
                              label: const Text('Browse Hotels'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final b = bookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          b.hotelName,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1A1A2E),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(b.status, theme),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          b.status.toUpperCase(),
                                          style: theme.textTheme.labelLarge
                                              ?.copyWith(
                                            color: _statusTextColor(
                                                b.status, theme),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.room_rounded,
                                          size: 16,
                                          color: Colors.grey.shade500),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Room ${b.roomNumber}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(Icons.calendar_today_rounded,
                                          size: 16,
                                          color: Colors.grey.shade500),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${fmt.format(b.checkIn)} → ${fmt.format(b.checkOut)}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.people_rounded,
                                          size: 16,
                                          color: Colors.grey.shade500),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${b.guests} guest${b.guests > 1 ? 's' : ''}',
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const Spacer(),
                                      if (b.razorpayPaymentId != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.payment_rounded,
                                                  size: 14,
                                                  color: Colors.green.shade700),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Paid',
                                                style: theme
                                                    .textTheme.labelLarge
                                                    ?.copyWith(
                                                  color: Colors.green.shade700,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: bookings.length,
                    ),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacementNamed('/home');
              break;
            case 1:
              break;
            case 2:
              Navigator.of(context).pushReplacementNamed('/profile');
              break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_rounded), label: 'Bookings'),
          NavigationDestination(
              icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
