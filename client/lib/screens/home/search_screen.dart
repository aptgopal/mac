import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/firestore_service.dart';
import '../../models/hotel.dart';
import '../../providers/currency_provider.dart';
import '../../screens/hotel/hotel_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _locationController = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  List<Hotel> _results = [];
  bool _loading = false;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select check-in and check-out dates'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final firestore = FirestoreService();
      final hotels = await firestore.streamSearchedHotels(
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        checkIn: _checkIn,
        checkOut: _checkOut,
        guests: _guests,
      ).first;

      setState(() {
        _results = hotels;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn
        ? (_checkIn ?? DateTime.now())
        : (_checkOut ?? (_checkIn ?? DateTime.now()).add(const Duration(days: 1)));
    final first = isCheckIn ? DateTime.now() : (_checkIn ?? DateTime.now()).add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF003580)),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && _checkOut!.isBefore(picked.add(const Duration(days: 1)))) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    final theme = Theme.of(context);
    final currency = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            floating: false,
            pinned: true,
            backgroundColor: theme.colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF003580), Color(0xFF0066CC)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Hotels',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _locationController,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: 'Where are you going?',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFF003580)),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(isCheckIn: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF003580)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _checkIn == null ? 'Check-in' : fmt.format(_checkIn!),
                                          style: TextStyle(
                                            color: _checkIn == null ? Colors.grey.shade500 : Colors.black87,
                                            fontWeight: _checkIn == null ? FontWeight.normal : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(isCheckIn: false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF003580)),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _checkOut == null ? 'Check-out' : fmt.format(_checkOut!),
                                          style: TextStyle(
                                            color: _checkOut == null ? Colors.grey.shade500 : Colors.black87,
                                            fontWeight: _checkOut == null ? FontWeight.normal : FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.people_rounded, size: 18, color: Color(0xFF003580)),
                              const SizedBox(width: 10),
                              Text(
                                '$_guests guest${_guests > 1 ? "s" : ""}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _guests > 1
                                        ? () => setState(() => _guests--)
                                        : null,
                                    icon: Icon(Icons.remove_circle_rounded, color: _guests > 1 ? theme.colorScheme.primary : Colors.grey.shade400),
                                  ),
                                  IconButton(
                                    onPressed: _guests < 10
                                        ? () => setState(() => _guests++)
                                        : null,
                                    icon: Icon(Icons.add_circle_rounded, color: _guests < 10 ? theme.colorScheme.primary : Colors.grey.shade400),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _search,
                  icon: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.search_rounded),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),
          ),
          if (_results.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${_results.length} results found',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          _results.isEmpty && _locationController.text.isEmpty && _checkIn == null
              ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Icon(Icons.search_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Search for available hotels',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : _results.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No results found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try different dates or nearby locations',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final hotel = _results[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => HotelDetailScreen(hotel: hotel),
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16),
                                        ),
                                        child: hotel.imageUrl.isNotEmpty
                                            ? Image.network(
                                                hotel.imageUrl,
                                                height: 180,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, o, s) => Container(
                                                  height: 180,
                                                  color: theme.colorScheme.primaryContainer,
                                                  child: Icon(Icons.hotel_rounded, size: 40, color: theme.colorScheme.primary),
                                                ),
                                              )
                                            : Container(
                                                height: 180,
                                                color: theme.colorScheme.primaryContainer,
                                                child: Icon(Icons.hotel_rounded, size: 40, color: theme.colorScheme.primary),
                                              ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    hotel.name,
                                                    style: theme.textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF1A1A2E),
                                                    ),
                                                  ),
                                                ),
                                                if (hotel.rating > 0)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFC107).withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                                                        const SizedBox(width: 4),
                                                        Text(
                                                          '${hotel.rating}',
                                                          style: theme.textTheme.labelLarge?.copyWith(
                                                            color: const Color(0xFF1A1A2E),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(Icons.location_on_rounded, size: 14, color: Colors.grey.shade500),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    hotel.location,
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  currency.format(hotel.pricePerNight, decimals: 0),
                                                  style: theme.textTheme.titleLarge?.copyWith(
                                                    color: theme.colorScheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '/ night',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: Colors.grey.shade500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: _results.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
