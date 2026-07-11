class Room {
  final String id;
  final String hotelId;
  final String type;
  final double price;
  final int totalRooms;
  final int availableRooms;
  final List<String> amenities;
  final DateTime? createdAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    required this.totalRooms,
    required this.availableRooms,
    required this.amenities,
    this.createdAt,
  });

  factory Room.fromMap(String id, String hotelId, Map<String, dynamic> map) {
    return Room(
      id: id,
      hotelId: hotelId,
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      totalRooms: (map['totalRooms'] ?? 0).toInt(),
      availableRooms: (map['availableRooms'] ?? 0).toInt(),
      amenities: List<String>.from(map['amenities'] ?? []),
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'price': price,
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'amenities': amenities,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
