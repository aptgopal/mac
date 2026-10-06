import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../services/firestore_service.dart';
import '../../services/currency_service.dart';
import 'room_form_screen.dart';

class ManageRoomsScreen extends StatelessWidget {
  const ManageRoomsScreen({super.key});

  FirestoreService get _firestore => FirestoreService();

  Future<void> _openForm(BuildContext context, [String? hotelId]) async {
    final hotels = await _firestore.streamHotels().first;
    if (hotels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a hotel first.')),
      );
      return;
    }
    final result = await Navigator.of(context).push<List<Room>>(
      MaterialPageRoute(builder: (_) => RoomFormScreen(hotels: hotels, initialHotelId: hotelId)),
    );
    if (result == null || result.isEmpty) return;
    await _firestore.addRooms(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.length} room(s) added successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rooms & Availability'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Room'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, hotelSnap) {
          if (!hotelSnap.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF003580)));
          }
          final hotels = hotelSnap.data!;
          if (hotels.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.meeting_room_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels yet.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return DefaultTabController(
            length: hotels.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: hotels.map<Widget>((h) => Tab(text: h.name)).toList(),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: TabBarView(
                    children: hotels.map<Widget>((hotel) {
                      return _RoomList(
                        hotelId: hotel.id,
                        hotelName: hotel.name,
                        firestore: _firestore,
                      );
                    }).toList(),
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
  const _RoomList({required this.hotelId, required this.hotelName, required this.firestore});

  Color _statusColor(String status) {
    switch (status) {
      case 'AVAILABLE':
        return const Color(0xFF00C853);
      case 'BLOCKED':
      case 'BOOKED':
        return const Color(0xFFD32F2F);
      case 'MAINTENANCE':
        return const Color(0xFFFFC107);
      default:
        return Colors.grey;
    }
  }

  Widget _typeSummary(List<Room> rooms) {
    final counts = <String, List<int>>{};
    for (final r in rooms) {
      final c = counts.putIfAbsent(r.type, () => [0, 0]);
      c[0]++;
      if (r.status == 'AVAILABLE') c[1]++;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: counts.entries.map((e) {
            return Chip(
              backgroundColor: const Color(0xFF003580).withOpacity(0.08),
              label: Text(
                '${e.key}: ${e.value[0]} room${e.value[0] == 1 ? '' : 's'} (${e.value[1]} available)',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _blockRoom(BuildContext context, Room room) async {
    final noteCtrl = TextEditingController();
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Block Room ${room.roomNumber}'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, 'DATES'), child: const Text('Block for dates')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, 'WALK_IN'), child: const Text('Hold for walk-in')),
        ],
      ),
    );
    final note = noteCtrl.text.trim();
    noteCtrl.dispose();
    if (choice == null) return;
    if (choice == 'WALK_IN') {
      await firestore.blockRoomForWalkIn(hotelId, room.id,
          note: note.isEmpty ? 'Walk-in' : note);
      return;
    }
    if (!context.mounted) return;
    final start = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (start == null || !context.mounted) return;
    final end = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(days: 1)),
      firstDate: start.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 91)),
    );
    if (end == null) return;
    await firestore.blockRoom(room.id, start, end, note.isEmpty ? 'Blocked' : note,
        hotelId: hotelId);
  }

  Widget _blockButton(BuildContext context, Room room) {
    final unblockable = room.status == 'BLOCKED' || room.status == 'MAINTENANCE';
    return IconButton(
      icon: Icon(unblockable ? Icons.lock_open_rounded : Icons.block_rounded, size: 20),
      tooltip: unblockable ? 'Make available' : 'Block / hold for walk-in',
      onPressed: unblockable
          ? () => firestore.unblockRoom(room.hotelId, room.id)
          : room.status == 'AVAILABLE'
              ? () => _blockRoom(context, room)
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Room>>(
      stream: firestore.streamRooms(hotelId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF003580)));
        }
        final rooms = snapshot.data!;
        if (rooms.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.meeting_room_rounded, size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text('No rooms for $hotelName', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        return Column(
          children: [
            _typeSummary(rooms),
            Expanded(
              child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;
            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                  dataRowMinHeight: 64,
                  dataRowMaxHeight: 64,
                  columns: const [
                    DataColumn(label: Text('Room')),
                    DataColumn(label: Text('Type')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Bed')),
                    DataColumn(label: Text('Capacity')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: rooms.map((room) {
                    return DataRow(
                      cells: [
                        DataCell(Text('Room ${room.roomNumber}', style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(room.type)),
                        DataCell(Text(CurrencyService.formatInr(room.price, decimals: 0))),
                        DataCell(Text(room.bedType)),
                        DataCell(Text('${room.maxOccupancy} guests')),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(room.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              room.status,
                              style: TextStyle(
                                color: _statusColor(room.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              _blockButton(context, room),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 20),
                                tooltip: 'Edit',
                                onPressed: () async {
                                  final hotels = await firestore.streamHotels().first;
                                  if (context.mounted) {
                                    final result = await Navigator.of(context).push<Room>(
                                      MaterialPageRoute(builder: (_) => RoomFormScreen(hotels: hotels, room: room)),
                                    );
                                    if (result != null) {
                                      await firestore.updateRoom(result);
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                tooltip: 'Delete',
                                onPressed: () => firestore.deleteRoom(room.hotelId, room.id),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _statusColor(room.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                room.roomNumber,
                                style: TextStyle(
                                  color: _statusColor(room.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.type,
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                                ),
                                const SizedBox(height: 4),
                                  Text(
                                    CurrencyService.formatInr(room.price, decimals: 0),
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(room.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              room.status,
                              style: TextStyle(
                                color: _statusColor(room.status),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _blockButton(context, room),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 20),
                            tooltip: 'Edit',
                            onPressed: () async {
                              final hotels = await firestore.streamHotels().first;
                              if (context.mounted) {
                                final result = await Navigator.of(context).push<Room>(
                                  MaterialPageRoute(builder: (_) => RoomFormScreen(hotels: hotels, room: room)),
                                );
                                if (result != null) {
                                  await firestore.updateRoom(result);
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 20),
                            tooltip: 'Delete',
                            onPressed: () => firestore.deleteRoom(room.hotelId, room.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
              ),
            ),
          ],
        );
      },
    );
  }
}
