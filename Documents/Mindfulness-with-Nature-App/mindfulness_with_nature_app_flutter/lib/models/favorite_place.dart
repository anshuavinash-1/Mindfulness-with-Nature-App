class FavoritePlace {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? description;
  final DateTime addedAt;
  final String userId;

  FavoritePlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.description,
    required this.addedAt,
    required this.userId,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'addedAt': addedAt.toIso8601String(),
      'userId': userId,
    };
  }

  // Create from JSON for retrieval
  factory FavoritePlace.fromJson(Map<String, dynamic> json) {
    return FavoritePlace(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      addedAt: DateTime.parse(json['addedAt']),
      userId: json['userId'],
    );
  }
}
