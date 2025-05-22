import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mvvm_flutter/features/user/model/user_model.dart';
import '../model/post_model.dart';
import 'post_state.dart';
import 'post_events.dart';

class PostController extends ChangeNotifier {
  PostState _state = PostInitial();
  PostState get state => _state;

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  void onEvent(dynamic event){
    if (event is FetchPosts) {
      _fetchPosts();
    } else if (event is FetchPostDetail){
      _fetchPostDetail(event.postId);
    }
  }

  Future<void> _fetchPosts() async {
      _state = PostLoading();
      notifyListeners();

      try {
        final response = await http.get(Uri.parse('$baseUrl/posts'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final posts = data.map((e) => Post.fromJson(e)).toList();
          _state = PostLoaded(posts);
        } else {
          _state = PostError("Failed to load posts: ${response.statusCode}");
        }
      } catch (e) {
        _state = PostError("Error: $e");
      }

      notifyListeners();
  }

  Future<void> _fetchPostDetail(int postId) async {
  _state = PostLoading();
  notifyListeners();

  try {
    final postResponse = await http.get(Uri.parse('$baseUrl/posts/$postId'));

    if (postResponse.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(postResponse.body);
      final post = Post.fromJson(data);

      final userResponse = await http.get(Uri.parse('$baseUrl/users/${post.userId}'));
      User? user;

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        user = User.fromJson(userData);

        print('=== USER DATA ===');
            print('ID: ${user.id}');
            print('Name: ${user.name}');
            print('Username: ${user.username}');
            print('Email: ${user.email}');
            print('Phone: ${user.phone}');
            print('Website: ${user.website}');
            print('Address: ${user.address.street}, ${user.address.city}');
            print('Company: ${user.company.name}');
            print('=================');
      }

      _state = PostDetailLoaded(post, user: user);
    } else {
      _state = PostError("Failed to load post");
    }
  } catch (e) {
    _state = PostError("Error: $e");
  }

  notifyListeners();
}

}
