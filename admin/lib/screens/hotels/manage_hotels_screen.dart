import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common.dart';
import '../../theme/app_theme.dart';
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
    return AdminScaffold(
      route: '/hotels',
      title: 'Hotels',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add hotel'),
      ),
      body: StreamBuilder<List<Hotel>>(
        stream: _firestore.streamHotels(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final hotels = snapshot.data!;
          if (hotels.isEmpty) {
            return EmptyState(
              icon: Icons.hotel_outlined,
              title: 'No hotels yet',
              subtitle: 'Add your first property to get started.',
              action: ElevatedButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Add hotel'),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cols = constraints.maxWidth > 1100
                    ? 3
                    : (constraints.maxWidth > 720 ? 2 : 1);
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: hotels.length,
                  itemBuilder: (context, index) =>
                      _HotelCard(hotel: hotels[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _HotelCard extends StatelessWidget {
  final Hotel hotel;
  const _HotelCard({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              NetworkImageOrPlaceholder(
                url: hotel.imageUrl,
                height: 150,
                width: double.infinity,
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(hotel.location,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      hotel.description,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('From',
                              style: TextStyle(
                                  color: AppColors.muted, fontSize: 11)),
                          Text(
                            '${formatINR(hotel.pricePerNight)} / night',
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit',
                        onPressed: () => _openFormFor(context, hotel),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.danger),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDeleteFor(context, hotel),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFormFor(BuildContext context, Hotel h) {
    Navigator.of(context)
        .push<Hotel>(
          MaterialPageRoute(builder: (_) => HotelFormScreen(hotel: h)),
        )
        .then((result) async {
      if (result == null) return;
      final fs = FirestoreService();
      if (result.id.isEmpty) {
        await fs.addHotel(Hotel(
          id: '',
          name: result.name,
          location: result.location,
          description: result.description,
          imageUrl: result.imageUrl,
          pricePerNight: result.pricePerNight,
          createdAt: DateTime.now(),
        ));
      } else {
        await fs.updateHotel(result);
      }
    });
  }

  void _confirmDeleteFor(BuildContext context, Hotel h) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
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
    ).then((confirm) async {
      if (confirm == true) {
        await FirestoreService().deleteHotel(h.id);
      }
    });
  }
}
