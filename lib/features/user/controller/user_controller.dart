import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mvvm_flutter/features/post/controller/post_events.dart';
import 'package:mvvm_flutter/features/user/controller/user_events.dart';
import 'package:mvvm_flutter/features/user/controller/user_state.dart';
import '../model/user_model.dart';
import 'package:http/http.dart' as http;

class UserController extends ChangeNotifier {
  UserState _state = UserInitial();
  UserState get state => _state;

  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  void onEvent(dynamic event){
    if (event is FetchUsers) {
      _fetchUsers();
    } else if (event is FetchPostDetail){
      _fetchUserDetail(event.postId);
    }
  }

  Future<void> _fetchUsers() async {
      _state = UserLoading();
      notifyListeners();

      try {
        final response = await http.get(Uri.parse('$baseUrl/users'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          final users = data.map((e) => User.fromJson(e)).toList();
          _state = UserLoaded(users);
        } else {
          _state = UserError("Failed to load users: ${response.statusCode}");
        }
      } catch (e) {
        _state = UserError("Error: $e");
      }

      notifyListeners();
  }

  Future<void> _fetchUserDetail(int userId) async{
    _state = UserLoading();
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final post = User.fromJson(data);
        
        _state = UserDetailLoaded(post);
      } else {
        _state = UserError("Failed to load posts: ${response.statusCode}");
      }
    } catch (e) {
      _state = UserError("Error: $e");
    }
  }
}
