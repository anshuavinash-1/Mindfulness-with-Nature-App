import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../services/auth_service.dart';
import '../services/community_board_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isPosting = false;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _prefillUsername();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _prefillUsername() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    final derivedName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : (user?.email.split('@').first ?? 'Nature Lover');

    _usernameController.text = derivedName;
  }

  Future<void> _pickImage() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (!mounted || file == null) {
      return;
    }

    setState(() {
      _selectedImage = file;
    });
  }

  Future<void> _createPost() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    final username = _usernameController.text.trim();
    final content = _postController.text.trim();

    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to post to the community.'),
        ),
      );
      return;
    }

    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both username and post text.'),
        ),
      );
      return;
    }

    final filter = ProfanityFilter();
    if (filter.hasProfanity(content) || filter.hasProfanity(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Your post contains inappropriate language and cannot be submitted.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    await CommunityBoardService.addPost(
      userId: userId,
      username: username,
      content: content,
      image: _selectedImage,
    );

    if (!mounted) {
      return;
    }

    _postController.clear();
    setState(() {
      _selectedImage = null;
      _isPosting = false;
    });
  }

  Future<void> _refreshFeed() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }

  Future<void> _confirmDeletePost(CommunityPost post) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete post?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await CommunityBoardService.deletePost(postId: post.id, imageUrl: post.imageUrl);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted.')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshFeed,
                child: StreamBuilder<List<CommunityPost>>(
                  stream: CommunityBoardService.watchPosts(),
                  builder: (context, snapshot) {
                    final posts = snapshot.data ?? const <CommunityPost>[];

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Where do you find peace?',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCreatePostCard(theme),
                        const SizedBox(height: 26),
                        Text(
                          'Community Posts',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (snapshot.connectionState == ConnectionState.waiting)
                          const Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (snapshot.hasError)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Unable to load community posts right now.',
                            ),
                          )
                        else if (posts.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'No community posts yet. Share a mindful moment with the community.',
                            ),
                          )
                        else
                          ...posts.map((post) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildCommunityPost(
                                  post,
                                  theme,
                                  canDelete: currentUserId != null &&
                                      post.userId == currentUserId,
                                ),
                              )),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatePostCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _postController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What would you like to share?',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_selectedImage != null) _buildSelectedImagePreview(),
          if (_selectedImage != null) const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Attach Photo'),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _isPosting ? null : _createPost,
                icon: _isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_outlined),
                label: const Text('Post'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityPost(
    CommunityPost post,
    ThemeData theme, {
    required bool canDelete,
  }) {
    const avatarColor = Color(0xFF7A9F5A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    post.username.isNotEmpty
                        ? post.username[0].toUpperCase()
                        : 'N',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF374834),
                      ),
                    ),
                    Text(
                      _formatDateTime(post.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  tooltip: 'Delete post',
                  onPressed: () => _confirmDeletePost(post),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(height: 1.4),
          ),
          const SizedBox(height: 10),
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) _buildPostImage(post.imageUrl!),
        ],
      ),
    );
  }

  Widget _buildSelectedImagePreview() {
    if (_selectedImage == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Uint8List>(
      future: _selectedImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 170,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            snapshot.data!,
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildFallbackImage(),
          ),
        );
      },
    );
  }

  Widget _buildPostImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFDDE3C2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.landscape_outlined,
            color: Color(0xFF556B2F), size: 40),
      ),
    );
  }
}
