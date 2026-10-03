import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/firestore_service.dart';

class ProcessRefundScreen extends StatefulWidget {
  final String bookingId;
  const ProcessRefundScreen({super.key, required this.bookingId});

  @override
  State<ProcessRefundScreen> createState() => _ProcessRefundScreenState();
}

class _ProcessRefundScreenState extends State<ProcessRefundScreen> {
  final _amountController = TextEditingController();
  bool _processing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processRefund() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }
    setState(() => _processing = true);
    try {
      await FirestoreService().processRefund(widget.bookingId, amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Refund processed successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refund failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Process Refund')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Refund Amount',
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _processRefund,
                child: _processing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Process Refund'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
