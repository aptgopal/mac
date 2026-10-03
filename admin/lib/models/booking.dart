class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String roomId;
  final String roomType;
  final String roomNumber;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String guestName;
  final String guestEmail;
  final String guestPhone;
  final String status;
  final String paymentStatus;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? razorpayRefundId;
  final DateTime? refundedAt;
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.roomId,
    required this.roomType,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.guestName,
    required this.guestEmail,
    required this.guestPhone,
    this.status = 'PENDING',
    this.paymentStatus = 'PENDING',
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.razorpayRefundId,
    this.refundedAt,
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
      roomNumber: map['roomNumber'] ?? '',
      checkIn: (map['checkIn'] as dynamic).toDate(),
      checkOut: (map['checkOut'] as dynamic).toDate(),
      guests: (map['guests'] ?? 1).toInt(),
      guestName: map['guestName'] ?? '',
      guestEmail: map['guestEmail'] ?? '',
      guestPhone: map['guestPhone'] ?? '',
      status: map['status'] ?? 'PENDING',
      paymentStatus: map['paymentStatus'] ?? 'PENDING',
      razorpayOrderId: map['razorpayOrderId'],
      razorpayPaymentId: map['razorpayPaymentId'],
      razorpaySignature: map['razorpaySignature'],
      razorpayRefundId: map['razorpayRefundId'],
      refundedAt: map['refundedAt']?.toDate(),
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
      'roomNumber': roomNumber,
      'checkIn': checkIn,
      'checkOut': checkOut,
      'guests': guests,
      'guestName': guestName,
      'guestEmail': guestEmail,
      'guestPhone': guestPhone,
      'status': status,
      'paymentStatus': paymentStatus,
      if (razorpayOrderId != null) 'razorpayOrderId': razorpayOrderId,
      if (razorpayPaymentId != null) 'razorpayPaymentId': razorpayPaymentId,
      if (razorpaySignature != null) 'razorpaySignature': razorpaySignature,
      if (razorpayRefundId != null) 'razorpayRefundId': razorpayRefundId,
      if (refundedAt != null) 'refundedAt': refundedAt,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
