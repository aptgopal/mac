import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../models/room.dart';

class RoomFormScreen extends StatefulWidget {
  final List<Hotel> hotels;
  final Room? room;
  final String? initialHotelId;
  const RoomFormScreen({super.key, required this.hotels, this.room, this.initialHotelId});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _hotelId;
  final _type = TextEditingController();
  final _price = TextEditingController();
  final _roomNumber = TextEditingController();
  final _bedType = TextEditingController(text: 'Single');
  final _maxOccupancy = TextEditingController(text: '2');
  final _squareFootage = TextEditingController();
  final _amenities = TextEditingController();
  late String _status;
  final bool _isRange = false;
  final _rangeStart = TextEditingController();
  final _rangeEnd = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _hotelId = r?.hotelId ??
        (widget.hotels.any((h) => h.id == widget.initialHotelId)
            ? widget.initialHotelId!
            : widget.hotels.first.id);
    _type.text = r?.type ?? '';
    _price.text = r != null ? r.price.toString() : '';
    _roomNumber.text = r?.roomNumber ?? '';
    _bedType.text = r?.bedType ?? 'Single';
    _maxOccupancy.text = r != null ? r.maxOccupancy.toString() : '2';
    _squareFootage.text = r != null ? (r.squareFootage?.toString() ?? '') : '';
    _amenities.text = r != null ? r.amenities.join(', ') : '';
    _status = r?.status ?? 'AVAILABLE';
  }

  @override
  void dispose() {
    _type.dispose();
    _price.dispose();
    _roomNumber.dispose();
    _bedType.dispose();
    _maxOccupancy.dispose();
    _squareFootage.dispose();
    _amenities.dispose();
    _rangeStart.dispose();
    _rangeEnd.dispose();
    super.dispose();
  }

  List<Room> _buildRooms() {
    final roomNumbers = <String>[];
    
    if (_isRange) {
      final start = int.tryParse(_rangeStart.text.trim()) ?? 1;
      final end = int.tryParse(_rangeEnd.text.trim()) ?? start;
      final s = start < end ? start : end;
      final e = start < end ? end : start;
      
      for (int i = s; i <= e; i++) {
        roomNumbers.add(i.toString());
      }
    } else {
      final text = _roomNumber.text.trim();
      if (text.isEmpty) {
        roomNumbers.add('1');
      } else if (text.contains(',') || text.contains('-')) {
        final parts = text.split(',');
        for (final part in parts) {
          final trimmed = part.trim();
          if (trimmed.contains('-')) {
            final rangeParts = trimmed.split('-');
            final start = int.tryParse(rangeParts[0].trim()) ?? 1;
            final end = int.tryParse(rangeParts[1].trim()) ?? start;
            final s = start < end ? start : end;
            final e = start < end ? end : start;
            for (int i = s; i <= e; i++) {
              roomNumbers.add(i.toString());
            }
          } else {
            roomNumbers.add(trimmed);
          }
        }
      } else {
        roomNumbers.add(text);
      }
    }

    return roomNumbers.map((number) {
      return Room(
        id: '',
        hotelId: _hotelId,
        type: _type.text.trim(),
        price: double.tryParse(_price.text) ?? 0,
        roomNumber: number,
        bedType: _bedType.text.trim(),
        maxOccupancy: int.tryParse(_maxOccupancy.text) ?? 2,
        squareFootage: _squareFootage.text.isNotEmpty ? int.tryParse(_squareFootage.text) : null,
        amenities: _amenities.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        status: _status,
        createdAt: DateTime.now(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Room' : 'Add Room')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 32 : 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                        ),
                        child: Text(
                          isEdit ? 'Update room details below' : 'Add a new room to a hotel',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _buildDropdown(
                                    value: _hotelId,
                                    label: 'Hotel',
                                    items: widget.hotels
                                        .map((h) => DropdownMenuItem(
                                              value: h.id,
                                              child: Text(h.name),
                                            ))
                                        .toList(),
                                    onChanged: (v) => setState(() => _hotelId = v ?? _hotelId),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(_type, 'Room Type', 'Deluxe, Suite...', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildField(_roomNumber, 'Room Number', '302', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildField(_price, 'Price (INR)', '0', (v) => double.tryParse(v ?? '') != null ? null : 'Number', keyboardType: TextInputType.number),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(_amenities, 'Amenities', 'WiFi, TV, AC (comma separated)', null),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildField(_bedType, 'Bed Type', 'Single, Double, King', null),
                                  const SizedBox(height: 16),
                                  _buildField(_maxOccupancy, 'Max Occupancy', '2', null, keyboardType: TextInputType.number),
                                  const SizedBox(height: 16),
                                  _buildField(_squareFootage, 'Square Footage (optional)', '200', null, keyboardType: TextInputType.number),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _status,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                                        DropdownMenuItem(value: 'BLOCKED', child: Text('Blocked')),
                                        DropdownMenuItem(value: 'BOOKED', child: Text('Booked')),
                                        DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                                      ],
                                      onChanged: (v) => setState(() => _status = v ?? 'AVAILABLE'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildDropdown(
                              value: _hotelId,
                              label: 'Hotel',
                              items: widget.hotels
                                  .map((h) => DropdownMenuItem(
                                        value: h.id,
                                        child: Text(h.name),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _hotelId = v ?? _hotelId),
                            ),
                            const SizedBox(height: 16),
                            _buildField(_type, 'Room Type', 'Deluxe, Suite...', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                            const SizedBox(height: 16),
                            _buildField(_roomNumber, 'Room Number', '302', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                            const SizedBox(height: 16),
                            _buildField(_price, 'Price (INR)', '0', (v) => double.tryParse(v ?? '') != null ? null : 'Number', keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildField(_bedType, 'Bed Type', 'Single, Double, King', null),
                            const SizedBox(height: 16),
                            _buildField(_maxOccupancy, 'Max Occupancy', '2', null, keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildField(_squareFootage, 'Square Footage (optional)', '200', null, keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildField(_amenities, 'Amenities', 'WiFi, TV, AC (comma separated)', null),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'AVAILABLE', child: Text('Available')),
                                  DropdownMenuItem(value: 'BLOCKED', child: Text('Blocked')),
                                  DropdownMenuItem(value: 'BOOKED', child: Text('Booked')),
                                  DropdownMenuItem(value: 'MAINTENANCE', child: Text('Maintenance')),
                                ],
                                onChanged: (v) => setState(() => _status = v ?? 'AVAILABLE'),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_formKey.currentState!.validate()) return;
                                final rooms = _buildRooms();
                                final existing = widget.room;
                                if (existing != null) {
                                  final edited = rooms.first;
                                  Navigator.of(context).pop(Room(
                                    id: existing.id,
                                    hotelId: existing.hotelId,
                                    type: edited.type,
                                    price: edited.price,
                                    roomNumber: edited.roomNumber,
                                    bedType: edited.bedType,
                                    maxOccupancy: edited.maxOccupancy,
                                    squareFootage: edited.squareFootage,
                                    amenities: edited.amenities,
                                    status: edited.status,
                                    blockedUntil: existing.blockedUntil,
                                    bookedBy: existing.bookedBy,
                                    bookedUntil: existing.bookedUntil,
                                    createdAt: existing.createdAt,
                                  ));
                                } else {
                                  Navigator.of(context).pop(rooms);
                                }
                              },
                              child: Text(isEdit ? 'Update Room' : 'Add Room'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    String hint,
    String? Function(String?)? validator, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
