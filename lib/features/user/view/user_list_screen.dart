import 'package:flutter/material.dart';
import 'package:mvvm_flutter/features/user/controller/user_controller.dart';
import 'package:mvvm_flutter/features/user/controller/user_events.dart';
import 'package:mvvm_flutter/features/user/controller/user_state.dart';
import 'package:mvvm_flutter/features/user/view/user_detail_screen.dart';
import 'package:mvvm_flutter/widgets/drawer_menu.dart';
import 'package:mvvm_flutter/widgets/error_state_widget.dart';
import 'package:mvvm_flutter/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when widget first appears
    Future.microtask(() {
      final controller = Provider.of<UserController>(context, listen: false);
      controller.onEvent(FetchUsers());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);

    return Scaffold(
      drawer: const DrawerMenu(),
      appBar: AppBar(
        title: Text('Users'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              controller.onEvent(FetchUsers());
            },
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          final state = controller.state;
          if (state is UserError) {
            return ErrorStateWidget(
              message: state.message,
              onPressed: () {
                controller.onEvent(FetchUsers());
              },
            );
          }
          if (state is! UserLoaded) {
            // Cegah tampilan "Unknown state"
            Future.microtask(() {
              controller.onEvent(FetchUsers());
            });
            return LoadingIndicator(title: "Reloading users...");
          } else {
            return RefreshIndicator(
              onRefresh: () async {
                controller.onEvent(FetchUsers());
              },
              child: state.users.isEmpty
                  ? _buildEmptyState()
                  : _buildPostList(state),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new users functionality
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Add post feature coming soon')),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add new post',
      ),
    );
  }

  Widget _buildPostList(UserLoaded state) {
    return ListView.separated(
      padding: EdgeInsets.all(8),
      itemCount: state.users.length,
      separatorBuilder: (context, index) => SizedBox(height: 6),
      itemBuilder: (context, index) {
        final user = state.users[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            child: Text(user.name[0], style: TextStyle(fontSize: 24)),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () {
            // Nanti bisa navigate ke detail user
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserDetailScreen(
                  user: user,
                ),
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
