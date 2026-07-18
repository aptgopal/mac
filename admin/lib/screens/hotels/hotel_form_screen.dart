import 'package:flutter/material.dart';
import '../../models/hotel.dart';
import '../../widgets/common.dart';

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
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Hotel' : 'Add Hotel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: 'Hotel details'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _name,
                        decoration:
                            const InputDecoration(labelText: 'Hotel name'),
                        validator: (v) => v != null && v.isNotEmpty
                            ? null
                            : 'Required',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _location,
                        decoration:
                            const InputDecoration(labelText: 'Location'),
                        validator: (v) => v != null && v.isNotEmpty
                            ? null
                            : 'Required',
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                            labelText: 'Description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _imageUrl,
                        decoration: const InputDecoration(
                            labelText: 'Image URL',
                            hintText: 'https://...'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _price,
                        decoration: const InputDecoration(
                            labelText: 'Price per night (₹)'),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v != null && double.tryParse(v) != null
                                ? null
                                : 'Enter a number',
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            Navigator.of(context)
                                .pop(_buildModel(widget.hotel?.id ?? ''));
                          },
                          child: Text(isEdit ? 'Save changes' : 'Create hotel'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
