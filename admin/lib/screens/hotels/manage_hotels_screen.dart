import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../services/firestore_service.dart';
import 'hotel_form_screen.dart';

class ManageHotelsScreen extends StatelessWidget {
  ManageHotelsScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  Future<void> _openForm(BuildContext context, [Hotel? hotel]) async {
    final result = await Navigator.of(context).push<Hotel>(
      MaterialPageRoute(builder: (_) => HotelFormScreen(hotel: hotel)),
    );
    if (result == null) return;
    if (result.id.isEmpty) {
      await _firestore.addHotel(Hotel(
        id: '',
        name: result.name,
        location: result.location,
        description: result.description,
        imageUrl: result.imageUrl,
        pricePerNight: result.pricePerNight,
        createdAt: DateTime.now(),
      ));
    } else {
      await _firestore.updateHotel(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Hotels')),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return const Center(child: Text('No hotels yet.'));
          }
          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return ListTile(
                leading: hotel.imageUrl.isNotEmpty
                    ? Image.network(hotel.imageUrl,
                        width: 56, height: 56, fit: BoxFit.cover)
                    : const Icon(Icons.hotel),
                title: Text(hotel.name),
                subtitle: Text(hotel.location),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openForm(context, hotel),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete hotel?'),
                            content: const Text(
                                'This also deletes its rooms.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _firestore.deleteHotel(hotel.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
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
