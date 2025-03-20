class User {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;
  final List<String> rideHistory;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
    this.rideHistory = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      imageUrl: json['imageUrl'] as String?,
      rideHistory: List<String>.from(json['rideHistory'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'rideHistory': rideHistory,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    List<String>? rideHistory,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      rideHistory: rideHistory ?? this.rideHistory,
    );
  }
}