import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/hotel.dart';
import '../../services/firestore_service.dart';
import '../../services/currency_service.dart';
import '../../models/room.dart';
import '../rooms/room_form_screen.dart';
import 'hotel_form_screen.dart';

class ManageHotelsScreen extends StatelessWidget {
  const ManageHotelsScreen({super.key});

  FirestoreService get _firestore => FirestoreService();

  Future<void> _addRooms(BuildContext context, Hotel hotel) async {
    final hotels = await _firestore.streamHotels().first;
    if (!context.mounted) return;
    final result = await Navigator.of(context).push<List<Room>>(
      MaterialPageRoute(
        builder: (_) => RoomFormScreen(hotels: hotels, initialHotelId: hotel.id),
      ),
    );
    if (result == null || result.isEmpty) return;
    await _firestore.addRooms(result);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${result.length} room(s) added to ${hotel.name}')),
      );
    }
  }

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
        latitude: result.latitude,
        longitude: result.longitude,
        rating: result.rating,
        distance: result.distance,
        status: result.status,
        createdAt: DateTime.now(),
      ));
    } else {
      await _firestore.updateHotel(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotels'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: () => _openForm(context),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add Hotel'),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF003580)));
          }
          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return Center(
              child: Column(
                children: [
                  Icon(Icons.hotel_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No hotels yet.',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              if (isWide) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8F9FA)),
                    dataRowMinHeight: 72,
                    dataRowMaxHeight: 72,
                    columns: const [
                      DataColumn(label: Text('Hotel')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Rating')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: hotels.map((hotel) {
                      final isActive = hotel.status == 'ACTIVE';
                      return DataRow(
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: hotel.imageUrl.isNotEmpty
                                      ? Image.network(
                                          hotel.imageUrl,
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, o, s) => Container(
                                            width: 44,
                                            height: 44,
                                            color: Colors.grey.shade200,
                                            child: Icon(Icons.hotel_rounded, size: 24, color: Colors.grey.shade400),
                                          ),
                                        )
                                      : Container(
                                          width: 44,
                                          height: 44,
                                          color: Colors.grey.shade200,
                                          child: Icon(Icons.hotel_rounded, size: 24, color: Colors.grey.shade400),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    hotel.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(hotel.location, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          DataCell(
                            hotel.rating > 0
                                ? Row(
                                    children: [
                                      const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                                      const SizedBox(width: 4),
                                      Text('${hotel.rating}'),
                                    ],
                                  )
                                : const Text('-'),
                          ),
                          DataCell(Text(CurrencyService.formatInr(hotel.pricePerNight, decimals: 0))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF00C853).withOpacity(0.1) : const Color(0xFFD32F2F).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  color: isActive ? const Color(0xFF00C853) : const Color(0xFFD32F2F),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                    size: 20,
                                  ),
                                  tooltip: isActive ? 'Deactivate' : 'Activate',
                                  onPressed: () => _firestore.updateHotelStatus(
                                    hotel.id,
                                    isActive ? 'INACTIVE' : 'ACTIVE',
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_home_work_rounded, size: 20),
                                  tooltip: 'Add rooms',
                                  onPressed: () => _addRooms(context, hotel),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded, size: 20),
                                  tooltip: 'Edit',
                                  onPressed: () => _openForm(context, hotel),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        title: const Text('Delete hotel?'),
                                        content: const Text('This also deletes its rooms.'),
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
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: hotels.length,
                itemBuilder: (context, index) {
                  final hotel = hotels[index];
                  final isActive = hotel.status == 'ACTIVE';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: hotel.imageUrl.isNotEmpty
                                      ? Image.network(
                                          hotel.imageUrl,
                                          width: 72,
                                          height: 72,
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, o, s) => Container(
                                            width: 72,
                                            height: 72,
                                            color: theme.colorScheme.primaryContainer,
                                            child: Icon(Icons.hotel_rounded, size: 32, color: theme.colorScheme.primary),
                                          ),
                                        )
                                      : Container(
                                          width: 72,
                                          height: 72,
                                          color: theme.colorScheme.primaryContainer,
                                          child: Icon(Icons.hotel_rounded, size: 32, color: theme.colorScheme.primary),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel.name,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1A1A2E),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
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
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          if (hotel.rating > 0) ...[
                                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC107)),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${hotel.rating}',
                                              style: theme.textTheme.labelLarge?.copyWith(
                                                color: const Color(0xFF1A1A2E),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                          ],
                                          Text(
                                            CurrencyService.formatInr(hotel.pricePerNight, decimals: 0),
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isActive ? const Color(0xFF00C853).withOpacity(0.1) : const Color(0xFFD32F2F).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: isActive ? const Color(0xFF00C853) : const Color(0xFFD32F2F),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            isActive ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                            size: 20,
                                          ),
                                          tooltip: isActive ? 'Deactivate' : 'Activate',
                                          onPressed: () => _firestore.updateHotelStatus(
                                            hotel.id,
                                            isActive ? 'INACTIVE' : 'ACTIVE',
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_home_work_rounded, size: 20),
                                          tooltip: 'Add rooms',
                                          onPressed: () => _addRooms(context, hotel),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded, size: 20),
                                          tooltip: 'Edit',
                                          onPressed: () => _openForm(context, hotel),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                          tooltip: 'Delete',
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: const Text('Delete hotel?'),
                                                content: const Text('This also deletes its rooms.'),
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
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
