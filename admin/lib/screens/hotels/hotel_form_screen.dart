import 'package:flutter/material.dart';
import '../models/hotel.dart';

class HotelFormScreen extends StatefulWidget {
  final Hotel? hotel;
  const HotelFormScreen({super.key, this.hotel});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late final TextEditingController _imageUrl;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _name = TextEditingController(text: h?.name ?? '');
    _location = TextEditingController(text: h?.location ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _imageUrl = TextEditingController(text: h?.imageUrl ?? '');
    _price = TextEditingController(
        text: h != null ? h.pricePerNight.toString() : '');
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _imageUrl.dispose();
    _price.dispose();
    super.dispose();
  }

  Hotel _buildModel(String id) {
    return Hotel(
      id: id,
      name: _name.text.trim(),
      location: _location.text.trim(),
      description: _description.text.trim(),
      imageUrl: _imageUrl.text.trim(),
      pricePerNight: double.tryParse(_price.text) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hotel != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Hotel' : 'Add Hotel')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                    v != null && v.isNotEmpty ? null : 'Required',
              ),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _imageUrl,
                decoration:
                    const InputDecoration(labelText: 'Image URL'),
              ),
              TextFormField(
                controller: _price,
                decoration:
                    const InputDecoration(labelText: 'Price per night'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v != null && double.tryParse(v) != null
                        ? null
                        : 'Enter a number',
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.of(context).pop(_buildModel(widget.hotel?.id ?? ''));
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
