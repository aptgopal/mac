import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../hotel/hotel_detail_screen.dart';
import 'booking_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _startBooking(BuildContext context, Hotel hotel) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user == null) {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(returnToPrevious: true),
        ),
      );
      if (signedIn != true || !context.mounted) return;
    }

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingSelectionScreen(hotel: hotel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final theme = Theme.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<List<Hotel>>(
        stream: firestore.streamHotels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'We could not load the lodge details.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return _EmptyHome(theme: theme);
          }

          final hotel = hotels.first;
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                backgroundColor: const Color(0xFF003580),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsetsDirectional.only(
                    start: 20,
                    bottom: 16,
                    end: 20,
                  ),
                  title: Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hotel.imageUrl.isNotEmpty)
                        Image.network(
                          hotel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _heroPlaceholder(theme),
                        )
                      else
                        _heroPlaceholder(theme),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black26,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            stops: [0, 0.35, 1],
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 62),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded,
                                      color: Color(0xFF008A5B), size: 17),
                                  SizedBox(width: 6),
                                  Text(
                                    'Your next stay',
                                    style: TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Color(0xFF0066CC), size: 19),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  hotel.location,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hotel.rating > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF003580),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${hotel.rating}/5',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F1FC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.hotel_rounded,
                                color: Color(0xFF003580)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Rooms from',
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${currency.format(hotel.pricePerNight, decimals: 0)} / night',
                                  style: const TextStyle(
                                    color: Color(0xFF003580),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (hotel.distance.isNotEmpty)
                            Text(
                              hotel.distance,
                              style: theme.textTheme.labelMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'About this stay',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hotel.description.isNotEmpty
                          ? hotel.description
                          : 'A comfortable stay, thoughtfully prepared for your next trip.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'A better stay starts here',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF1A1A2E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _AmenityChip(
                            icon: Icons.event_available_rounded,
                            label: 'Flexible dates'),
                        _AmenityChip(
                            icon: Icons.meeting_room_rounded,
                            label: 'Choose your room'),
                        _AmenityChip(
                            icon: Icons.support_agent_rounded,
                            label: 'Easy booking'),
                      ],
                    ),
                    const SizedBox(height: 22),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HotelDetailScreen(hotel: hotel),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('View lodge details'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: const Color(0xFF003580),
                        side: const BorderSide(color: Color(0xFFCCD8E6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: StreamBuilder<List<Hotel>>(
        stream: firestore.streamHotels(),
        builder: (context, snapshot) {
          final hotel =
              snapshot.hasData && snapshot.data!.isNotEmpty ? snapshot.data!.first : null;
          if (hotel == null) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currency.format(hotel.pricePerNight, decimals: 0),
                          style: const TextStyle(
                            color: Color(0xFF003580),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const Text('per night',
                            style:
                                TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _startBooking(context, hotel),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Book now',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _heroPlaceholder(ThemeData theme) => Container(
        color: theme.colorScheme.primaryContainer,
        child: Icon(Icons.hotel_rounded,
            size: 84, color: theme.colorScheme.primary),
      );
}

class _EmptyHome extends StatelessWidget {
  final ThemeData theme;

  const _EmptyHome({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hotel_rounded,
                  size: 68, color: Colors.grey.shade400),
              const SizedBox(height: 18),
              Text(
                'Your next stay is coming soon',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'There are no active lodges to show right now. Please check back soon.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF0066CC)),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF344054), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
