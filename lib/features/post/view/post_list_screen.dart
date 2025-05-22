import 'package:flutter/material.dart';
import 'package:mvvm_flutter/features/post/view/post_detail_screen.dart';
import 'package:mvvm_flutter/widgets/drawer_menu.dart';
import 'package:mvvm_flutter/widgets/error_state_widget.dart';
import 'package:mvvm_flutter/widgets/loading_indicator.dart';
import 'package:mvvm_flutter/widgets/post_card.dart';
import 'package:provider/provider.dart';
import '../controller/post_controller.dart';
import '../controller/post_state.dart';
import '../controller/post_events.dart';

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when widget first appears
    Future.microtask(() {
      final controller = Provider.of<PostController>(context, listen: false);
      controller.onEvent(FetchPosts());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<PostController>(context);

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: Text('Posts'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.onEvent(FetchPosts());
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          final state = controller.state;
          if (state is PostError) {
            return ErrorStateWidget(
              message: state.message,
              onPressed: () {
                controller.onEvent(FetchPosts());
              },
            );
          }
          if (state is! PostLoaded) {
            // Cegah tampilan "Unknown state"
            Future.microtask(() {
              controller.onEvent(FetchPosts());
            });
            return LoadingIndicator(title: "Reloading posts...");
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                controller.onEvent(FetchPosts());
              },
              child: state.posts.isEmpty
                  ? _buildEmptyState()
                  : _buildPostList(state),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new post functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add post feature coming soon')),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add new post',
      ),
    );
  }

  Widget _buildPostList(PostLoaded state) {
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: state.posts.length,
      separatorBuilder: (context, index) => SizedBox(height: 6),
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return PostCard(
          post: post,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailScreen(post: post),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No posts available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
