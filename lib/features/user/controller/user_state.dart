import '../model/user_model.dart';

abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserDetailLoading extends UserState {}

class UserLoaded extends UserState {
  final List<User> users;
  UserLoaded(this.users);
}

class UserDetailLoaded extends UserState {
  final User user;
  UserDetailLoaded(this.user);
}


class UserError extends UserState {
  final String message;
  UserError(this.message);
}
