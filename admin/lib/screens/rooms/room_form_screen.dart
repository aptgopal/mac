import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/room.dart';

class RoomFormScreen extends StatefulWidget {
  final List<Hotel> hotels;
  final Room? room;
  const RoomFormScreen({super.key, required this.hotels, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _hotelId;
  final _type = TextEditingController();
  final _price = TextEditingController();
  final _total = TextEditingController();
  final _available = TextEditingController();
  final _amenities = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.room;
    _hotelId = r?.hotelId ?? widget.hotels.first.id;
    _type.text = r?.type ?? '';
    _price.text = r != null ? r.price.toString() : '';
    _total.text = r != null ? r.totalRooms.toString() : '';
    _available.text = r != null ? r.availableRooms.toString() : '';
    _amenities.text = r != null ? r.amenities.join(', ') : '';
  }

  @override
  void dispose() {
    _type.dispose();
    _price.dispose();
    _total.dispose();
    _available.dispose();
    _amenities.dispose();
    super.dispose();
  }

  Room _build(String id) {
    return Room(
      id: id,
      hotelId: _hotelId,
      type: _type.text.trim(),
      price: double.tryParse(_price.text) ?? 0,
      totalRooms: int.tryParse(_total.text) ?? 0,
      availableRooms: int.tryParse(_available.text) ?? 0,
      amenities: _amenities.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Room' : 'Add Room')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                value: _hotelId,
                decoration: const InputDecoration(labelText: 'Hotel'),
                items: widget.hotels
                    .map((h) => DropdownMenuItem(
                          value: h.id,
                          child: Text(h.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _hotelId = v!),
              ),
              TextFormField(
                controller: _type,
                decoration: const InputDecoration(labelText: 'Room type'),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    double.tryParse(v ?? '') != null ? null : 'Number',
              ),
              TextFormField(
                controller: _total,
                decoration:
                    const InputDecoration(labelText: 'Total rooms'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') != null ? null : 'Number',
              ),
              TextFormField(
                controller: _available,
                decoration: const InputDecoration(
                    labelText: 'Available rooms'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    int.tryParse(v ?? '') != null ? null : 'Number',
              ),
              TextFormField(
                controller: _amenities,
                decoration: const InputDecoration(
                    labelText: 'Amenities (comma separated)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(_build(widget.room?.id ?? ''));
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
