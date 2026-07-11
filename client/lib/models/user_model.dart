class UserModel {
  final String uid;
  final String email;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
