import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/hotel.dart';
import '../../screens/hotel/hotel_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lodges'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => Navigator.of(context).pushNamed('/bookings'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).pushNamed('/profile'),
          ),
        ],
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: firestore.streamHotels(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return const Center(child: Text('No lodges available yet.'));
          }
          return ListView.builder(
            itemCount: hotels.length,
            itemBuilder: (context, index) {
              final hotel = hotels[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: hotel.imageUrl.isNotEmpty
                      ? Image.network(hotel.imageUrl,
                          width: 64, height: 64, fit: BoxFit.cover)
                      : const Icon(Icons.hotel, size: 48),
                  title: Text(hotel.name),
                  subtitle: Text(
                      '${hotel.location} • \$${hotel.pricePerNight.toStringAsFixed(0)}/night'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HotelDetailScreen(hotel: hotel),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
