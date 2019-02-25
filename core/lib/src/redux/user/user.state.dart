import 'package:core/src/models/user/user.dart';
import 'package:core/src/models/loading_status/loading_status.dart';
import 'package:meta/meta.dart';

@immutable
class UserState {
  UserState({
    this.user
  });

  final User user;

  factory UserState.initial() {
    return UserState(
      user: null
    );
  }

  UserState copyWith({
    User user
  }) {
    return UserState(
      user: user ?? this.user
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is UserState &&
        runtimeType == other.runtimeType &&
        user == other.user;
  }

  @override
  int get hashCode =>
    user.hashCode;
}