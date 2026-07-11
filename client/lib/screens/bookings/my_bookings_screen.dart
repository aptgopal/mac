import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/booking.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final firestore = FirestoreService();
    final fmt = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: firestore.streamUserBookings(auth.user!.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const Center(child: Text('You have no bookings yet.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(b.hotelName),
                  subtitle: Text(
                    '${b.roomType} • ${b.guests} guests\n'
                    '${fmt.format(b.checkIn)} → ${fmt.format(b.checkOut)}',
                  ),
                  trailing: Chip(
                    label: Text(b.status),
                    backgroundColor: b.status == 'confirmed'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
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
