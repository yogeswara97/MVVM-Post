import 'package:flutter/material.dart';
import 'package:mvvm_flutter/features/user/controller/user_controller.dart';
import 'package:mvvm_flutter/features/user/controller/user_events.dart';
import 'package:mvvm_flutter/features/user/controller/user_state.dart';
import 'package:mvvm_flutter/features/user/model/user_model.dart';
import 'package:mvvm_flutter/widgets/error_state_widget.dart';
import 'package:mvvm_flutter/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch detailed post data when screen initializes
    Future.microtask(() {
      final controller = Provider.of<UserController>(context, listen: false);
      controller.onEvent(FetchUserDetail(widget.user.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<UserController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("User Detail"),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (_) {
          final state = controller.state;

          if (state is UserError) {
            return ErrorStateWidget(
              message: state.message,
              onPressed: () {
                controller.onEvent(FetchUserDetail(widget.user.id));
              },
            );
          }

          if (state is! UserDetailLoaded) {
            // Cegah tampilan "Unknown state"
            Future.microtask(() {
              controller.onEvent(FetchUserDetail(widget.user.id));
            });
            return LoadingIndicator(title: "Loading user...");
          }

          return _buildDetailContent(context, state.user);
        },
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(user),
          const SizedBox(height: 24),
          _buildSection("Contact", [
            _buildInfoRow(Icons.email, user.email),
            _buildInfoRow(Icons.phone, user.phone),
            _buildInfoRow(Icons.language, user.website),
          ]),
          const SizedBox(height: 24),
          _buildSection("Address", [
            _buildInfoRow(
                Icons.home, "${user.address.street}, ${user.address.suite}"),
            _buildInfoRow(Icons.location_city, user.address.city),
            _buildInfoRow(Icons.location_on,
                "Lat: ${user.address.geo.lat}, Lng: ${user.address.geo.lng}"),
          ]),
          const SizedBox(height: 24),
          _buildSection("Company", [
            _buildInfoRow(Icons.business, user.company.name),
            _buildInfoRow(Icons.bolt, user.company.catchPhrase),
            _buildInfoRow(Icons.work, user.company.bs),
          ]),
        ],
      ),
    );
  }

  Widget _buildUserHeader(User user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          child: Text(user.name[0], style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.name,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('@${user.username}',
                style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800])),
        const SizedBox(height: 8),
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
