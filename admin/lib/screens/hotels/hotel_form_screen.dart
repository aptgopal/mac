import 'package:flutter/material.dart';
import '../../models/hotel.dart';

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
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _rating;
  late final TextEditingController _distance;
  late String _status;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _name = TextEditingController(text: h?.name ?? '');
    _location = TextEditingController(text: h?.location ?? '');
    _description = TextEditingController(text: h?.description ?? '');
    _imageUrl = TextEditingController(text: h?.imageUrl ?? '');
    _price = TextEditingController(text: h != null ? h.pricePerNight.toString() : '');
    _latitude = TextEditingController(text: h != null ? h.latitude.toString() : '');
    _longitude = TextEditingController(text: h != null ? h.longitude.toString() : '');
    _rating = TextEditingController(text: h != null ? h.rating.toString() : '');
    _distance = TextEditingController(text: h?.distance ?? '');
    _status = h?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _description.dispose();
    _imageUrl.dispose();
    _price.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _rating.dispose();
    _distance.dispose();
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
      latitude: double.tryParse(_latitude.text) ?? 0,
      longitude: double.tryParse(_longitude.text) ?? 0,
      rating: int.tryParse(_rating.text) ?? 3,
      distance: _distance.text.trim(),
      status: _status,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hotel != null;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Hotel' : 'Add Hotel'),
      ),
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
                          isEdit ? 'Update hotel information below' : 'Fill in the details to add a new hotel',
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
                                  _buildField(_name, 'Hotel Name', 'Enter hotel name', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                                  const SizedBox(height: 16),
                                  _buildField(_location, 'Location', 'City, Country', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                                  const SizedBox(height: 16),
                                  _buildField(_description, 'Description', 'Describe the property', null, maxLines: 3),
                                  const SizedBox(height: 16),
                                  _buildField(_imageUrl, 'Image URL', 'https://...', null),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  _buildField(_price, 'Price per Night (INR)', '0', (v) => v != null && double.tryParse(v) != null ? null : 'Enter a number', keyboardType: TextInputType.number),
                                  const SizedBox(height: 16),
                                  _buildField(_rating, 'Rating (1-5)', '3', (v) => v != null && int.tryParse(v) != null ? null : 'Enter a number', keyboardType: TextInputType.number),
                                  const SizedBox(height: 16),
                                  _buildField(_distance, 'Distance', '2.3 km', null),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildField(_latitude, 'Latitude', '0.0', null, keyboardType: TextInputType.number),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildField(_longitude, 'Longitude', '0.0', null, keyboardType: TextInputType.number),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      value: _status,
                                      decoration: const InputDecoration(
                                        labelText: 'Status',
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                                        DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                                      ],
                                      onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
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
                            _buildField(_name, 'Hotel Name', 'Enter hotel name', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                            const SizedBox(height: 16),
                            _buildField(_location, 'Location', 'City, Country', (v) => v != null && v.isNotEmpty ? null : 'Required'),
                            const SizedBox(height: 16),
                            _buildField(_description, 'Description', 'Describe the property', null, maxLines: 3),
                            const SizedBox(height: 16),
                            _buildField(_imageUrl, 'Image URL', 'https://...', null),
                            const SizedBox(height: 16),
                            _buildField(_price, 'Price per Night (INR)', '0', (v) => v != null && double.tryParse(v) != null ? null : 'Enter a number', keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildField(_rating, 'Rating (1-5)', '3', (v) => v != null && int.tryParse(v) != null ? null : 'Enter a number', keyboardType: TextInputType.number),
                            const SizedBox(height: 16),
                            _buildField(_distance, 'Distance', '2.3 km', null),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildField(_latitude, 'Latitude', '0.0', null, keyboardType: TextInputType.number),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildField(_longitude, 'Longitude', '0.0', null, keyboardType: TextInputType.number),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _status,
                                decoration: const InputDecoration(
                                  labelText: 'Status',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                                ],
                                onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
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
                                Navigator.of(context).pop(_buildModel(widget.hotel?.id ?? ''));
                              },
                              child: Text(isEdit ? 'Update Hotel' : 'Add Hotel'),
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
}
