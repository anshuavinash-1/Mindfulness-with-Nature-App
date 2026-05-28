import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/community_post.dart';
import '../services/auth_service.dart';
import '../services/community_board_service.dart';

class CommunityPage extends StatefulWidget {
  final Stream<List<CommunityPost>>? postsStream;

  const CommunityPage({super.key, this.postsStream});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _postController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isPosting = false;
  bool _canModeratePosts = false;
  String? _currentUserRole;
  XFile? _selectedImage;

  String? _resolvedUserId() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    try {
      return fb_auth.FirebaseAuth.instance.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _prefillUsername();
    _loadCurrentUserRole();
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
    fb_auth.User? firebaseUser;
    try {
      firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    } catch (_) {
      firebaseUser = null;
    }
    final fallbackEmail = firebaseUser?.email;
    final fallbackName = firebaseUser?.displayName;

    final derivedName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : ((fallbackName?.trim().isNotEmpty == true)
            ? fallbackName!.trim()
            : ((user?.email ?? fallbackEmail)?.split('@').first ??
                'Nature Lover'));

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
    final userId = _resolvedUserId();
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
      authorRole: _currentUserRole,
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

  Future<void> _loadCurrentUserRole() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final claims = await authService.getCurrentUserClaims(forceRefresh: true);

    String? role;
    if (claims['owner'] == true) {
      role = 'OWNER';
    } else if (claims['admin'] == true) {
      role = 'ADMIN';
    } else if (claims['moderator'] == true) {
      role = 'MODERATOR';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserRole = role;
      _canModeratePosts = role != null;
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

    await CommunityBoardService.deletePost(
        postId: post.id, imageUrl: post.imageUrl);

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
    final currentUserId = _resolvedUserId();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshFeed,
                child: StreamBuilder<List<CommunityPost>>(
                  stream:
                      widget.postsStream ?? CommunityBoardService.watchPosts(),
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
                        _buildCreatePostCard(
                          theme,
                          canPost: currentUserId != null &&
                              currentUserId.trim().isNotEmpty,
                        ),
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
                                      (post.userId == currentUserId ||
                                          _canModeratePosts),
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

  Widget _buildCreatePostCard(ThemeData theme, {required bool canPost}) {
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
          if (!canPost)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'Guests can browse community posts but must sign in to create a post.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
              ),
            ),
          TextField(
            key: const Key('community-username-field'),
            controller: _usernameController,
            enabled: canPost,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('community-post-field'),
            controller: _postController,
            enabled: canPost,
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
                key: const Key('community-attach-button'),
                onPressed: canPost ? _pickImage : null,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Attach Photo'),
              ),
              const Spacer(),
              FilledButton.icon(
                key: const Key('community-post-button'),
                onPressed: !canPost || _isPosting ? null : _createPost,
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
                    if (post.authorRole != null && post.authorRole!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D4A34),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            post.authorRole!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            _buildPostImage(post.imageUrl!),
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
    return FutureBuilder<String?>(
      future: _resolveDisplayImageUrl(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final resolvedUrl = snapshot.data;
        if (resolvedUrl == null || resolvedUrl.isEmpty) {
          return _buildFallbackImage();
        }

        return InkWell(
          key: const Key('community-image-preview'),
          onTap: () => _openImageViewer(resolvedUrl),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 220,
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.05),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      resolvedUrl,
                      fit: BoxFit.contain,
                      // On Flutter web, Firebase Storage media URLs may fail in the
                      // default image codec path due to browser CORS restrictions.
                      // Using an HTML img element keeps rendering reliable.
                      webHtmlElementStrategy: kIsWeb
                          ? WebHtmlElementStrategy.prefer
                          : WebHtmlElementStrategy.never,
                      errorBuilder: (_, __, ___) => _buildFallbackImage(),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Tap to expand',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openImageViewer(String imageUrl) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          backgroundColor: Colors.black,
          child: Column(
            children: [
              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      key: const Key('community-viewer-close-icon'),
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Spacer(),
                    TextButton(
                      key: const Key('community-viewer-close-button'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 5,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      webHtmlElementStrategy: kIsWeb
                          ? WebHtmlElementStrategy.prefer
                          : WebHtmlElementStrategy.never,
                      errorBuilder: (_, __, ___) => _buildFallbackImage(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _resolveDisplayImageUrl(String source) async {
    final trimmed = source.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    try {
      if (trimmed.startsWith('gs://')) {
        return FirebaseStorage.instance.refFromURL(trimmed).getDownloadURL();
      }

      return FirebaseStorage.instance.ref(trimmed).getDownloadURL();
    } catch (_) {
      return null;
    }
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
        child:
            Icon(Icons.landscape_outlined, color: Color(0xFF556B2F), size: 40),
      ),
    );
  }
}
