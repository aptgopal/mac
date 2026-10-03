import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final Hotel hotel;
  final Room room;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String guestName;
  final String guestEmail;
  final String guestPhone;

  const PaymentScreen({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final Razorpay _razorpay;
  bool _processing = true;
  bool _orderReady = false;
  String? _bookingId;
  String? _orderId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _initialize();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double get _amount {
    final nights = widget.checkOut.difference(widget.checkIn).inDays;
    return nights > 0 ? nights * widget.room.price : widget.room.price;
  }

  Future<void> _initialize() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final firestore = FirestoreService();
      await firestore.lockRoom(widget.room.id, auth.user?.uid ?? 'guest', const Duration(minutes: 10));

      final bookingId = await firestore.createBookingWithPayment(
        userId: auth.user?.uid ?? '',
        hotelId: widget.hotel.id,
        hotelName: widget.hotel.name,
        roomId: widget.room.id,
        roomType: widget.room.type,
        roomNumber: widget.room.roomNumber,
        checkIn: widget.checkIn,
        checkOut: widget.checkOut,
        guests: widget.guests,
        guestName: widget.guestName,
        guestEmail: widget.guestEmail,
        guestPhone: widget.guestPhone,
        amount: _amount,
      );

      setState(() {
        _bookingId = bookingId;
        _orderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
        _orderReady = true;
        _processing = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _processing = false;
      });
    }
  }

  Future<void> _verifyAndConfirm(String paymentId, String signature) async {
    final firestore = FirestoreService();
    await firestore.updateBookingPayment(
      _bookingId!,
      razorpayPaymentId: paymentId,
      razorpaySignature: signature,
      paymentStatus: 'PAID',
    );
    await firestore.updateBookingPayment(_bookingId!, paymentStatus: 'CONFIRMED');
    await firestore.releaseRoomLock(widget.room.id);
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C853), size: 56),
          title: const Text('Booking Confirmed', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Booking ID: $_bookingId', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Payment ID: $paymentId', style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _verifyAndConfirm(response.paymentId!, response.signature!);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    FirestoreService().releaseRoomLock(widget.room.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${response.message}'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      setState(() => _orderReady = true);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    FirestoreService().releaseRoomLock(widget.room.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('External wallet: ${response.walletName}'),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
    }
  }

  Future<void> _startPayment() async {
    if (_bookingId == null || _orderId == null) return;

    final options = {
      'key': 'YOUR_RAZORPAY_KEY',
      'amount': (_amount * 100).toInt(),
      'currency': 'INR',
      'name': widget.hotel.name,
      'description': 'Booking for Room ${widget.room.roomNumber}',
      'order_id': _orderId,
      'prefill': {
        'contact': widget.guestPhone,
        'email': widget.guestEmail,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    final theme = Theme.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await FirestoreService().releaseRoomLock(widget.room.id);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: _processing
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 64, color: Color(0xFFD32F2F)),
                          const SizedBox(height: 16),
                          Text('Error: $_error', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Go Back'),
                          ),
                        ],
                      ),
                    ),
                  )
                : CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 180,
                        floating: false,
                        pinned: true,
                        backgroundColor: theme.colorScheme.primary,
                        flexibleSpace: FlexibleSpaceBar(
                          background: widget.hotel.imageUrl.isNotEmpty
                              ? Image.network(
                                  widget.hotel.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, o, s) => Container(
                                    color: theme.colorScheme.primaryContainer,
                                    child: Icon(Icons.hotel_rounded, size: 60, color: theme.colorScheme.primary),
                                  ),
                                )
                              : Container(
                                  color: theme.colorScheme.primaryContainer,
                                  child: Icon(Icons.hotel_rounded, size: 60, color: theme.colorScheme.primary),
                                ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hotel.name,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    _PaymentRow(icon: Icons.meeting_room_rounded, label: 'Room', value: '${widget.room.roomNumber} (${widget.room.type})'),
                                    const SizedBox(height: 12),
                                    _PaymentRow(icon: Icons.calendar_today_rounded, label: 'Dates', value: '${fmt.format(widget.checkIn)} - ${fmt.format(widget.checkOut)}'),
                                    const SizedBox(height: 12),
                                    _PaymentRow(icon: Icons.people_rounded, label: 'Guests', value: '${widget.guests}'),
                                    const SizedBox(height: 12),
                                    _PaymentRow(icon: Icons.person_rounded, label: 'Guest', value: widget.guestName),
                                    const SizedBox(height: 12),
                                    _PaymentRow(icon: Icons.email_rounded, label: 'Email', value: widget.guestEmail),
                                    const SizedBox(height: 12),
                                    _PaymentRow(icon: Icons.phone_rounded, label: 'Phone', value: widget.guestPhone),
                                    const Divider(height: 24),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                        Text(
                                          currency.format(_amount, decimals: 2),
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFFFC107).withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.lock_clock_rounded, size: 18, color: Color(0xFFE65100)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Room ${widget.room.roomNumber} is locked for 10 minutes',
                                        style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.w500, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton.icon(
                                  onPressed: _orderReady ? _startPayment : null,
                                  icon: const Icon(Icons.payment_rounded),
                                  label: const Text('Proceed to Pay', style: TextStyle(fontSize: 16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PaymentRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
