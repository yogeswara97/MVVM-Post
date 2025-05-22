abstract class PostEvent {}

class FetchPosts extends PostEvent {}

class FetchPostDetail {
  final int postId;
  FetchPostDetail(this.postId);
}