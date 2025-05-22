abstract class UserEvent {}

class FetchUsers extends UserEvent {}

class FetchUserDetail extends UserEvent {
  final int userId;

  FetchUserDetail(this.userId);
}
