class UserModel {
  final String? id;
  final String fullName;
  final String email;

  const UserModel({
    this.id,
    required this.fullName,
    required this.email,
  });

  // Convert the user object to a Map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
    };
  }
  // Create a user object from a Map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  // Create a copy with updated values.
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }
}
