import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../payment/payment_screen.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  Future<void> _bookRoom(BuildContext context, Room room) async {
    final checkIn = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF003580)),
          ),
          child: child!,
        );
      },
    );
    if (checkIn == null) return;
    final checkOut = await showDatePicker(
      context: context,
      initialDate: checkIn.add(const Duration(days: 1)),
      firstDate: checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 366)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF003580)),
          ),
          child: child!,
        );
      },
    );
    if (checkOut == null) return;

    final nights = checkOut.difference(checkIn).inDays;
    if (nights <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Check-out must be after check-in')),
        );
      }
      return;
    }

    final guestsCtrl = TextEditingController(text: '1');
    final guestNameCtrl = TextEditingController();
    final guestEmailCtrl = TextEditingController();
    final guestPhoneCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Book ${room.type}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF003580).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF003580)),
                    const SizedBox(width: 8),
                    Text(
                      '$nights night${nights > 1 ? "s" : ""}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: guestNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guestEmailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guestPhoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'Enter your phone number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: guestsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Number of guests',
                  prefixIcon: Icon(Icons.people_outline_rounded),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (guestNameCtrl.text.trim().isEmpty ||
                  guestEmailCtrl.text.trim().isEmpty ||
                  guestPhoneCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all guest details')),
                );
                return;
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Continue to Payment'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            hotel: hotel,
            room: room,
            checkIn: checkIn,
            checkOut: checkOut,
            guests: int.tryParse(guestsCtrl.text) ?? 1,
            guestName: guestNameCtrl.text.trim(),
            guestEmail: guestEmailCtrl.text.trim(),
            guestPhone: guestPhoneCtrl.text.trim(),
          ),
        ),
      );
    }
  }

  Widget _buildRoomChip(Room room) {
    final available = room.isAvailable;
    return GestureDetector(
      onTap: available ? () {} : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: available
              ? const Color(0xFF00C853).withOpacity(0.08)
              : const Color(0xFFD32F2F).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: available
                ? const Color(0xFF00C853).withOpacity(0.3)
                : const Color(0xFFD32F2F).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              available ? Icons.check_circle_rounded : Icons.cancel_rounded,
              size: 16,
              color: available ? const Color(0xFF00C853) : const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 6),
            Text(
              'Room ${room.roomNumber}',
              style: TextStyle(
                color: available ? const Color(0xFF00C853) : const Color(0xFFD32F2F),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    final theme = Theme.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: StreamBuilder<List<Room>>(
        stream: firestore.streamRooms(hotel.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rooms = snapshot.data!;
          final roomsByType = <String, List<Room>>{};
          for (final room in rooms) {
            roomsByType.putIfAbsent(room.type, () => []).add(room);
          }
          final typeEntries = roomsByType.entries.toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                floating: false,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: hotel.imageUrl.isNotEmpty
                      ? Image.network(
                          hotel.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            color: theme.colorScheme.primaryContainer,
                            child: Icon(Icons.hotel_rounded, size: 80, color: theme.colorScheme.primary),
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.hotel_rounded, size: 80, color: theme.colorScheme.primary),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              hotel.name,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          if (hotel.rating > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 18, color: Color(0xFFFFC107)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${hotel.rating}',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              hotel.location,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hotel.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rooms',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '${rooms.length} available',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (rooms.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.meeting_room_rounded, size: 40, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No rooms listed for this lodge.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...List.generate(typeEntries.length, (i) {
                          final entry = typeEntries[i];
                          final type = entry.key;
                          final typeRooms = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            type,
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                         Text(
                                          currency.format(typeRooms.first.price, decimals: 0),
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Room ${typeRooms.first.roomNumber} • ${typeRooms.first.bedType} bed • Max ${typeRooms.first.maxOccupancy} guests',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                     Wrap(
                                       spacing: 8,
                                       runSpacing: 8,
                                       children: typeRooms.map((room) {
                                         return _buildRoomChip(room);
                                       }).toList(),
                                     ),
                                     const SizedBox(height: 12),
                                     if (typeRooms.any((r) => r.isAvailable))
                                       SizedBox(
                                         width: double.infinity,
                                         child: ElevatedButton(
                                           onPressed: () => _bookRoom(context, typeRooms.firstWhere((r) => r.isAvailable, orElse: () => typeRooms.first)),
                                           child: const Text('Book Now'),
                                         ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           );
                        }),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
    );
  }
}
