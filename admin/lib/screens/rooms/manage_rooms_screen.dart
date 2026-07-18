import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../theme/app_theme.dart';
import 'room_form_screen.dart';

class ManageRoomsScreen extends StatelessWidget {
  ManageRoomsScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  Future<void> _openForm(BuildContext context) async {
    final hotels = await _firestore.streamHotels().first;
    if (hotels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a hotel first.')),
      );
      return;
    }
    final result = await Navigator.of(context).push<Room>(
      MaterialPageRoute(builder: (_) => RoomFormScreen(hotels: hotels)),
    );
    if (result == null) return;
    await _firestore.addRoom(result);
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      route: '/rooms',
      title: 'Rooms & Availability',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add room'),
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, hotelSnap) {
          if (!hotelSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = hotelSnap.data!;
          if (hotels.isEmpty) {
            return const EmptyState(
              icon: Icons.hotel_outlined,
              title: 'No hotels yet',
              subtitle: 'Add a hotel before managing its rooms.',
            );
          }
          return DefaultTabController(
            length: hotels.length,
            child: Column(
              children: [
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    isScrollable: true,
                    tabs: [
                      for (final h in hotels) Tab(text: h.name),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: TabBarView(
                    children: [
                      for (final hotel in hotels)
                        _RoomList(
                          key: ValueKey(hotel.id),
                          hotelId: hotel.id,
                          hotelName: hotel.name,
                          firestore: _firestore,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  final String hotelId;
  final String hotelName;
  final FirestoreService firestore;
  const _RoomList({
    super.key,
    required this.hotelId,
    required this.hotelName,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      stream: firestore.streamRooms(hotelId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final rooms = snapshot.data!;
        if (rooms.isEmpty) {
          return EmptyState(
            icon: Icons.meeting_room_outlined,
            title: 'No rooms for $hotelName',
            subtitle: 'Add a room type to start tracking availability.',
            action: ElevatedButton.icon(
              onPressed: () async {
                final hotels = await firestore.streamHotels().first;
                final result = await Navigator.of(context).push<Room>(
                  MaterialPageRoute(
                      builder: (_) => RoomFormScreen(hotels: hotels)),
                );
                if (result != null) await firestore.addRoom(result);
              },
              icon: const Icon(Icons.add),
              label: const Text('Add room'),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(24),
          child: ListView.separated(
            itemCount: rooms.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _RoomCard(
              room: rooms[index],
              firestore: firestore,
            ),
          ),
        );
      },
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final FirestoreService firestore;
  const _RoomCard({required this.room, required this.firestore});

  @override
  Widget build(BuildContext context) {
    final ratio = room.totalRooms == 0
        ? 0.0
        : room.availableRooms / room.totalRooms;
    final availableColor = ratio > 0.5
        ? AppColors.success
        : (ratio > 0.2 ? AppColors.warning : AppColors.danger);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.meeting_room,
                      color: AppColors.primaryLight),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.type,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${formatINR(room.price)} / night',
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                _Stepper(
                  count: room.availableRooms,
                  total: room.totalRooms,
                  onDecrement: room.availableRooms > 0
                      ? () => _update(room.availableRooms - 1)
                      : null,
                  onIncrement: () => _update(room.availableRooms + 1),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.danger),
                  tooltip: 'Delete',
                  onPressed: () =>
                      firestore.deleteRoom(room.hotelId, room.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      color: availableColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${room.availableRooms}/${room.totalRooms} available',
                  style: TextStyle(
                      color: availableColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
            if (room.amenities.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final a in room.amenities) AppChip(label: a),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _update(int newAvailable) {
    firestore.updateRoom(Room(
      id: room.id,
      hotelId: room.hotelId,
      type: room.type,
      price: room.price,
      totalRooms: room.totalRooms,
      availableRooms: newAvailable,
      amenities: room.amenities,
    ));
  }
}

class _Stepper extends StatelessWidget {
  final int count;
  final int total;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  const _Stepper({
    required this.count,
    required this.total,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final dec = OutlinedButton(
      onPressed: onDecrement,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.remove, size: 18),
    );
    final inc = OutlinedButton(
      onPressed: onIncrement,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
      ),
      child: const Icon(Icons.add, size: 18),
    );
    return Row(
      children: [
        dec,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('$count',
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        ),
        inc,
      ],
    );
  }
}
