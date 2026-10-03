class Room {
  final String id;
  final String hotelId;
  final String type;
  final double price;
  final String roomNumber;
  final String bedType;
  final int maxOccupancy;
  final int? squareFootage;
  final List<String> amenities;
  final String status;
  final DateTime? blockedUntil;
  final String? bookedBy;
  final DateTime? bookedUntil;
  final DateTime? createdAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.type,
    required this.price,
    required this.roomNumber,
    required this.bedType,
    required this.maxOccupancy,
    this.squareFootage,
    required this.amenities,
    this.status = 'AVAILABLE',
    this.blockedUntil,
    this.bookedBy,
    this.bookedUntil,
    this.createdAt,
  });

  factory Room.fromMap(String id, String hotelId, Map<String, dynamic> map) {
    return Room(
      id: id,
      hotelId: hotelId,
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      roomNumber: map['roomNumber'] ?? '',
      bedType: map['bedType'] ?? 'Single',
      maxOccupancy: (map['maxOccupancy'] ?? 1).toInt(),
      squareFootage: map['squareFootage'] != null ? (map['squareFootage'] as num).toInt() : null,
      amenities: List<String>.from(map['amenities'] ?? []),
      status: map['status'] ?? 'AVAILABLE',
      blockedUntil: map['blockedUntil']?.toDate(),
      bookedBy: map['bookedBy'],
      bookedUntil: map['bookedUntil']?.toDate(),
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'price': price,
      'roomNumber': roomNumber,
      'bedType': bedType,
      'maxOccupancy': maxOccupancy,
      'amenities': amenities,
      'status': status,
      if (squareFootage != null) 'squareFootage': squareFootage,
      if (blockedUntil != null) 'blockedUntil': blockedUntil,
      if (bookedBy != null) 'bookedBy': bookedBy,
      if (bookedUntil != null) 'bookedUntil': bookedUntil,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  bool get isAvailable => status == 'AVAILABLE';
}
