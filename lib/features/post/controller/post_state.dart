import 'package:mvvm_flutter/features/user/model/user_model.dart';
import '../model/post_model.dart';

abstract class PostState {
  User? get user => null;
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostDetailLoading extends PostState {}

// New state for when post is loaded but user is still loading
class PostDetailLoadingUser extends PostState {
  final Post post;
  
  PostDetailLoadingUser(this.post);
}

class PostLoaded extends PostState {
  final List<Post> posts;
  
  PostLoaded(this.posts);
}

class PostDetailLoaded extends PostState {
  final Post post;
  @override
  final User? user;
  final bool userLoadingFailed;
  
  PostDetailLoaded(this.post, {this.user, this.userLoadingFailed = false});
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}