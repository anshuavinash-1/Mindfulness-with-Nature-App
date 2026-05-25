import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  final String id;
  final String userId;
  final String username;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  const CommunityPost({
    required this.id,
    required this.userId,
    required this.username,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'id': id,
      'username': username,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommunityPost.fromMap(String id, Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.tryParse(createdAtRaw?.toString() ?? '') ?? DateTime.now();

    return CommunityPost(
      id: id,
      userId: json['userId'] ?? '',
      username: json['username'] ?? json['authorName'] ?? 'Nature Lover',
      content: json['content'] ?? 'Shared a peaceful moment.',
      imageUrl: json['imageUrl'] ?? json['imagePath'],
      createdAt: createdAt,
    );
  }
}
