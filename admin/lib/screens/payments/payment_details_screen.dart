import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final String bookingId;
  const PaymentDetailsScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Details')),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: firestore.getPaymentByBookingId(bookingId).asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final payment = snapshot.data!;
          if (payment == null) {
            return const Center(child: Text('Payment not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _detailRow('Booking ID', payment['id'] ?? ''),
                      _detailRow('Payment Status', payment['paymentStatus'] ?? ''),
                      if (payment['razorpayOrderId'] != null)
                        _detailRow('Order ID', payment['razorpayOrderId']),
                      if (payment['razorpayPaymentId'] != null)
                        _detailRow('Payment ID', payment['razorpayPaymentId']),
                      if (payment['razorpaySignature'] != null)
                        _detailRow('Signature', payment['razorpaySignature']),
                      if (payment['razorpayRefundId'] != null)
                        _detailRow('Refund ID', payment['razorpayRefundId']),
                      if (payment['refundedAt'] != null)
                        _detailRow('Refunded At', DateFormat.yMMMd().add_jm().format((payment['refundedAt'] as dynamic).toDate())),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
