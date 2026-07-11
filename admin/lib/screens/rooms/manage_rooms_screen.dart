import 'package:flutter/material.dart';
import '../models/room.dart';
import '../services/firestore_service.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms & Availability')),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, hotelSnap) {
          if (!hotelSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = hotelSnap.data!;
          if (hotels.isEmpty) {
            return const Center(child: Text('No hotels yet.'));
          }
          return DefaultTabController(
            length: hotels.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: hotels.map((h) => Tab(text: h.name)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: hotels.map((hotel) {
                      return _RoomList(
                        hotelId: hotel.id,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RoomList extends StatelessWidget {
  final String hotelId;
  final FirestoreService firestore;
  const _RoomList({required this.hotelId, required this.firestore});

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
          return const Center(child: Text('No rooms for this hotel.'));
        }
        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return ListTile(
              title: Text(room.type),
              subtitle: Text(
                '\$${room.price.toStringAsFixed(0)} • '
                '${room.availableRooms}/${room.totalRooms} available',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    tooltip: 'Decrease available',
                    onPressed: room.availableRooms > 0
                        ? () => firestore.updateRoom(Room(
                              id: room.id,
                              hotelId: room.hotelId,
                              type: room.type,
                              price: room.price,
                              totalRooms: room.totalRooms,
                              availableRooms: room.availableRooms - 1,
                              amenities: room.amenities,
                            ))
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    tooltip: 'Increase available',
                    onPressed: () => firestore.updateRoom(Room(
                      id: room.id,
                      hotelId: room.hotelId,
                      type: room.type,
                      price: room.price,
                      totalRooms: room.totalRooms,
                      availableRooms: room.availableRooms + 1,
                      amenities: room.amenities,
                    )),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        firestore.deleteRoom(room.hotelId, room.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
