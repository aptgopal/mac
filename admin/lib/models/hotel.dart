class Hotel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double pricePerNight;
  final double latitude;
  final double longitude;
  final String status;
  final int rating;
  final String distance;
  final DateTime? createdAt;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.pricePerNight,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.status = 'ACTIVE',
    this.rating = 3,
    this.distance = '',
    this.createdAt,
  });

  factory Hotel.fromMap(String id, Map<String, dynamic> map) {
    return Hotel(
      id: id,
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerNight: (map['pricePerNight'] ?? 0).toDouble(),
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      status: map['status'] ?? 'ACTIVE',
      rating: (map['rating'] ?? 3).toInt(),
      distance: map['distance'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'description': description,
      'imageUrl': imageUrl,
      'pricePerNight': pricePerNight,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'rating': rating,
      'distance': distance,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
