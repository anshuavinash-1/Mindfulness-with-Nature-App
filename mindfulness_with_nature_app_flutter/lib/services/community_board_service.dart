import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../models/community_post.dart';

class CommunityBoardService {
  static final CollectionReference<Map<String, dynamic>> _postsCollection =
      FirebaseFirestore.instance.collection('community_posts');
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  static Stream<List<CommunityPost>> watchPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => CommunityPost.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  static Future<void> addPost({
    required String userId,
    required String username,
    required String content,
    XFile? image,
  }) async {
    final trimmedContent = content.trim();
    if (trimmedContent.isEmpty) {
      return;
    }

    final trimmedUsername = username.trim().isEmpty ? 'Nature Lover' : username.trim();
    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadImage(userId: userId, image: image);
    }

    await _postsCollection.add({
      'userId': userId,
      'username': trimmedUsername,
      'content': trimmedContent,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> _uploadImage({
    required String userId,
    required XFile image,
  }) async {
    final String safeUserId = userId.isEmpty ? 'anonymous' : userId;
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
    final ref = _storage.ref('community_posts/$safeUserId/$fileName');

    final bytes = await image.readAsBytes();
    final uploadTask = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return uploadTask.ref.getDownloadURL();
  }

  static Future<void> deletePost({
    required String postId,
    String? imageUrl,
  }) async {
    await _postsCollection.doc(postId).delete();

    if (imageUrl == null || imageUrl.isEmpty) {
      return;
    }

    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {
      // Keep post deletion successful even if image cleanup fails.
    }
  }
}
