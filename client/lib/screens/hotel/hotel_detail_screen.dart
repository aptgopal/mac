import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';

class HotelDetailScreen extends StatelessWidget {
  final Hotel hotel;
  const HotelDetailScreen({super.key, required this.hotel});

  Future<void> _bookRoom(BuildContext context, Room room) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final checkIn = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (checkIn == null) return;
    final checkOut = await showDatePicker(
      context: context,
      initialDate: checkIn.add(const Duration(days: 1)),
      firstDate: checkIn.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );
    if (checkOut == null) return;

    final guestsCtrl = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Book ${room.type}'),
        content: TextField(
          controller: guestsCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Number of guests'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirestoreService().createBooking(
        userId: auth.user!.uid,
        hotelId: hotel.id,
        hotelName: hotel.name,
        roomId: room.id,
        roomType: room.type,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: int.tryParse(guestsCtrl.text) ?? 1,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!')),  
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Booking failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: Text(hotel.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hotel.imageUrl.isNotEmpty)
            Image.network(hotel.imageUrl, height: 200, fit: BoxFit.cover),
          const SizedBox(height: 12),
          Text(hotel.location, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(hotel.description),
          const SizedBox(height: 16),
          const Text('Rooms', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          StreamBuilder<List<Room>>(
            stream: firestore.streamRooms(hotel.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final rooms = snapshot.data!;
              if (rooms.isEmpty) {
                return const Text('No rooms listed for this lodge.');
              }
              return Column(
                children: rooms.map((room) {
                  final available = room.isAvailable;
                  return Card(
                    child: ListTile(
                      title: Text(room.type),
                      subtitle: Text(
                        '${room.amenities.join(', ')}\n${room.availableRooms}/${room.totalRooms} available',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('\$${room.price.toStringAsFixed(0)}'),
                          ElevatedButton(
                            onPressed: available
                                ? () => _bookRoom(context, room)
                                : null,
                            child: Text(available ? 'Book' : 'Full'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
