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

  Future<void> _openForm(BuildContext context) async {
    final hotels = await _firestore.streamHotels().first;
    if (hotels.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a hotel first.')),
      );
      return;
    }
    final result = await Navigator.of(context).push<List<Room>>(
      MaterialPageRoute(builder: (_) => RoomFormScreen(hotels: hotels)),
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

  Future<void> _blockRoom(BuildContext context, Room room) async {
    final start = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (start == null) return;
    final end = await showDatePicker(
      context: context,
      initialDate: start.add(const Duration(days: 1)),
      firstDate: start.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 91)),
    );
    if (end == null) return;
    final reason = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Block Reason'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Reason'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, 'Blocked'), child: const Text('Block')),
        ],
      ),
    );
    if (reason != null) {
      await firestore.blockRoom(room.id, start, end, reason, hotelId: hotelId);
    }
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
        return LayoutBuilder(
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
                              IconButton(
                                icon: const Icon(Icons.block_rounded, size: 20),
                                tooltip: 'Block room',
                                onPressed: room.status == 'AVAILABLE'
                                    ? () => _blockRoom(context, room)
                                    : null,
                              ),
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
                          IconButton(
                            icon: const Icon(Icons.block_rounded, size: 20),
                            tooltip: 'Block room',
                            onPressed: room.status == 'AVAILABLE'
                                ? () => _blockRoom(context, room)
                                : null,
                          ),
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
        );
      },
    );
  }
}
