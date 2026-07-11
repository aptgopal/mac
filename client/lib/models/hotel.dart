class Hotel {
  final String id;
  final String name;
  final String location;
  final String description;
  final String imageUrl;
  final double pricePerNight;
  final DateTime? createdAt;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.imageUrl,
    required this.pricePerNight,
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
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
