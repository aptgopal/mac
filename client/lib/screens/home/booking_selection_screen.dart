import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';
import '../../providers/auth_provider.dart';
import '../../providers/currency_provider.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import '../payment/payment_screen.dart';

class BookingSelectionScreen extends StatefulWidget {
  final Hotel hotel;

  const BookingSelectionScreen({super.key, required this.hotel});

  @override
  State<BookingSelectionScreen> createState() =>
      _BookingSelectionScreenState();
}

class _BookingSelectionScreenState extends State<BookingSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTimeRange? _dates;
  String? _selectedRoomType;
  int _guests = 1;
  bool _openingPayment = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().firebaseUser;
    _nameController.text = user?.displayName ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDates() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final dates = await showDateRangePicker(
      context: context,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      initialDateRange: _dates ??
          DateTimeRange(start: today, end: today.add(const Duration(days: 1))),
      helpText: 'Select check-in and check-out',
      saveText: 'Done',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF003580)),
        ),
        child: child!,
      ),
    );
    if (dates != null && mounted) {
      setState(() => _dates = dates);
    }
  }

  List<Room> _availableRooms(List<Room> rooms, String roomType) {
    final checkIn = _dates?.start;
    return rooms.where((room) {
      if (room.type != roomType || room.status != 'AVAILABLE') return false;
      if (checkIn == null) return true;
      if (room.bookedUntil != null && room.bookedUntil!.isAfter(checkIn)) {
        return false;
      }
      if (room.blockedUntil != null && room.blockedUntil!.isAfter(checkIn)) {
        return false;
      }
      return true;
    }).toList();
  }

  Future<void> _continueToPayment(List<Room> rooms) async {
    if (!_formKey.currentState!.validate()) return;
    if (_dates == null || _selectedRoomType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select your dates and room type.')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    if (auth.user == null) {
      final signedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(returnToPrevious: true),
        ),
      );
      if (signedIn != true || !mounted) return;
    }

    final availableRooms = _availableRooms(rooms, _selectedRoomType!);
    if (availableRooms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That room type is no longer available for these dates.'),
        ),
      );
      return;
    }
    final room = availableRooms.first;
    if (_guests > room.maxOccupancy) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'This room accommodates up to ${room.maxOccupancy} guests.',
          ),
        ),
      );
      return;
    }

    setState(() => _openingPayment = true);
    try {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            hotel: widget.hotel,
            room: room,
            checkIn: _dates!.start,
            checkOut: _dates!.end,
            guests: _guests,
            guestName: _nameController.text.trim(),
            guestEmail: _emailController.text.trim(),
            guestPhone: _phoneController.text.trim(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<CurrencyProvider>();
    final dateFormat = DateFormat.MMMd();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Your stay'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
      ),
      body: StreamBuilder<List<Room>>(
        stream: FirestoreService().streamRooms(widget.hotel.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load rooms for this lodge.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rooms = snapshot.data!;
          final roomTypes = rooms
              .where((room) => room.status == 'AVAILABLE')
              .map((room) => room.type)
              .where((type) => type.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          if (_selectedRoomType != null &&
              !roomTypes.contains(_selectedRoomType)) {
            _selectedRoomType = null;
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                _LodgeSummary(
                  hotel: widget.hotel,
                  price: currency.format(widget.hotel.pricePerNight,
                      decimals: 0),
                ),
                const SizedBox(height: 22),
                Text('Choose your stay',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                _SelectionTile(
                  icon: Icons.calendar_month_rounded,
                  title: 'Check-in — check-out',
                  subtitle: _dates == null
                      ? 'Select your dates'
                      : '${dateFormat.format(_dates!.start)} – ${dateFormat.format(_dates!.end)}  ·  ${_dates!.duration.inDays} night${_dates!.duration.inDays == 1 ? '' : 's'}',
                  onTap: _selectDates,
                ),
                const SizedBox(height: 12),
                if (roomTypes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'No rooms are currently available. Please check back later.',
                    ),
                  )
                else
                  DropdownButtonFormField<String>(
                    value: _selectedRoomType,
                    decoration: InputDecoration(
                      labelText: 'Room type',
                      prefixIcon: const Icon(Icons.bed_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: roomTypes.map((type) {
                      final options = _availableRooms(rooms, type);
                      final price = options.isNotEmpty
                          ? options.first.price
                          : rooms
                              .firstWhere((room) => room.type == type)
                              .price;
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          '$type  ·  ${currency.format(price, decimals: 0)}/night',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedRoomType = value),
                    validator: (value) =>
                        value == null ? 'Choose a room type' : null,
                  ),
                if (_selectedRoomType != null) ...[
                  const SizedBox(height: 10),
                  Builder(
                    builder: (context) {
                      final available =
                          _availableRooms(rooms, _selectedRoomType!);
                      if (_dates != null && available.isEmpty) {
                        return const Text(
                          'No rooms of this type are available for the selected check-in date.',
                          style: TextStyle(
                              color: Color(0xFFB42318), fontSize: 13),
                        );
                      }
                      final sample = available.isNotEmpty
                          ? available.first
                          : rooms.firstWhere(
                              (room) => room.type == _selectedRoomType,
                            );
                      return Text(
                        '${_dates == null ? available.length : available.length} room${available.length == 1 ? '' : 's'} available · Up to ${sample.maxOccupancy} guests per room',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 22),
                Text('Guest details',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter the guest name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) =>
                      value != null && value.trim().contains('@')
                          ? null
                          : 'Enter a valid email address',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) =>
                      value == null || value.trim().length < 7
                          ? 'Enter a valid phone number'
                          : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: _guests,
                  decoration: const InputDecoration(
                    labelText: 'Guests',
                    prefixIcon: Icon(Icons.people_outline_rounded),
                  ),
                  items: List.generate(
                    10,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1} guest${index == 0 ? '' : 's'}'),
                    ),
                  ),
                  onChanged: (value) =>
                      setState(() => _guests = value ?? 1),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: roomTypes.isEmpty || _openingPayment
                      ? null
                      : () => _continueToPayment(rooms),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _openingPayment
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Continue to booking',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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

class _LodgeSummary extends StatelessWidget {
  final Hotel hotel;
  final String price;

  const _LodgeSummary({required this.hotel, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            height: 96,
            child: hotel.imageUrl.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFE8F1FC),
                    child: Icon(Icons.hotel_rounded,
                        color: Color(0xFF003580), size: 34),
                  )
                : Image.network(
                    hotel.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE8F1FC),
                      child: Icon(Icons.hotel_rounded,
                          color: Color(0xFF003580), size: 34),
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hotel.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Text('$price / night',
                      style: const TextStyle(
                          color: Color(0xFF003580),
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF003580)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF667085), fontSize: 14)),
                  ],
                ),
              ),
              const Icon(Icons.edit_calendar_rounded,
                  color: Color(0xFF667085), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
