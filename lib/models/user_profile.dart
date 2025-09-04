class UserProfile {
  final String id;
  final String? phone;
  final String role;

  UserProfile({
    required this.id,
    required this.phone,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      phone: map['phone'],
      role: map['role'] ?? 'ASHA_WORKER', // Default role if not set
    );
  }
}

