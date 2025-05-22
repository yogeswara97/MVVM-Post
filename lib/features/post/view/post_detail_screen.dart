import 'package:flutter/material.dart';
import 'package:mvvm_flutter/features/post/controller/post_controller.dart';
import 'package:mvvm_flutter/features/post/controller/post_state.dart';
import 'package:mvvm_flutter/features/post/controller/post_events.dart';
import 'package:mvvm_flutter/features/post/model/post_model.dart';
import 'package:mvvm_flutter/features/user/model/user_model.dart';
import 'package:mvvm_flutter/widgets/error_state_widget.dart';
import 'package:mvvm_flutter/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch detailed post data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<PostController>(context, listen: false);
      controller.onEvent(FetchPostDetail(widget.post.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post Detail"),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bookmark feature coming soon')),
              );
            },
          ),
        ],
      ),
      body: Consumer<PostController>(
        builder: (context, controller, child) {
          final state = controller.state;

          if (state is PostDetailLoading) {
            return const Center(
              child: LoadingIndicator(title: "Loading post..."),
            );
          } else if (state is PostDetailLoadingUser) {
            // Show post content with loading indicator for user
            return _buildDetailContentWithUserLoading(context, state.post);
          } else if (state is PostDetailLoaded) {
            // Print user data when loaded
            if (state.user != null) {
              print('=== USER IN UI ===');
              print('User: ${state.user!.name}');
              print('Email: ${state.user!.email}');
              print('==================');
            }
            return _buildDetailContent(context, state.post, state.user, state.userLoadingFailed);
          } else if (state is PostError) {
            return ErrorStateWidget(
              message: state.message,
              onPressed: () {
                controller.onEvent(FetchPostDetail(widget.post.id));
              },
            );
          }

          // Fallback
          return _buildDetailContent(context, widget.post, null, false);
        },
      ),
    );
  }

  Widget _buildDetailContentWithUserLoading(BuildContext context, Post post) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentSection(context, post),
          _buildLoadingAuthorSection(context, post),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Post post, User? user, bool userLoadingFailed) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentSection(context, post),
          _buildAuthorSection(context, post, user, userLoadingFailed),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, Post post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Post title
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),

          // Post body
          Text(
            post.body,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingAuthorSection(BuildContext context, Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[400],
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 180,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: null,
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[400],
            ),
            child: const Text('Loading...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorSection(BuildContext context, Post post, User? user, bool userLoadingFailed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: userLoadingFailed ? Colors.red[400] : Colors.blue[700],
            child: userLoadingFailed
                ? const Icon(Icons.error, color: Colors.white)
                : Text(
                    user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? (userLoadingFailed ? 'Failed to load user' : 'User ${post.userId}'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                if (user?.email.isNotEmpty == true)
                  Text(
                    user!.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  )
                else if (userLoadingFailed)
                  Text(
                    "User information unavailable",
                    style: TextStyle(color: Colors.red[600], fontSize: 14),
                  )
                else
                  Text(
                    "Contributing writer",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: userLoadingFailed
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Follow feature coming soon')),
                    );
                  },
            style: TextButton.styleFrom(
              foregroundColor: userLoadingFailed ? Colors.grey[400] : Colors.blue[700],
            ),
            child: Text(userLoadingFailed ? 'Unavailable' : 'Follow'),
          ),
        ],
      ),
    );
  }
}