class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String roomId;
  final String roomType;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String status;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomType,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.status,
    this.createdAt,
  });

  factory Booking.fromMap(String id, Map<String, dynamic> map) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      hotelId: map['hotelId'] ?? '',
      hotelName: map['hotelName'] ?? '',
      roomId: map['roomId'] ?? '',
      roomType: map['roomType'] ?? '',
      checkIn: (map['checkIn'] as dynamic).toDate(),
      checkOut: (map['checkOut'] as dynamic).toDate(),
      guests: (map['guests'] ?? 1).toInt(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'roomId': roomId,
      'roomType': roomType,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'status': status,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
