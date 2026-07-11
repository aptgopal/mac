import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import '../services/firestore_service.dart';

class ManageBookingsScreen extends StatelessWidget {
  ManageBookingsScreen({super.key});

  final FirestoreService _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: StreamBuilder<List<Booking>>(
        stream: _firestore.streamBookings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bookings = snapshot.data!;
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet.'));
          }
          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return ListTile(
                title: Text('${b.hotelName} — ${b.roomType}'),
                subtitle: Text(
                  '${b.guests} guests • '
                  '${fmt.format(b.checkIn)} → ${fmt.format(b.checkOut)}',
                ),
                trailing: DropdownButton<String>(
                  value: b.status,
                  items: const [
                    DropdownMenuItem(
                        value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(
                        value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (status) {
                    if (status != null) {
                      _firestore.updateBookingStatus(b.id, status);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
