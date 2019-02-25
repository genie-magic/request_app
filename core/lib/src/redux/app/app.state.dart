import 'package:core/src/redux/user/user.state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  AppState({
    @required this.userState
  });

  final UserState userState;

  factory AppState.initial() {
    return AppState(
      userState: UserState.initial()
    );
  }

  AppState copyWith({
    AppState userState
  }) {
    return AppState(
      userState: userState ?? this.userState
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is AppState &&
        runtimeType == other.runtimeType &&
        userState == other.userState;
  }

  @override
  int get hashCode =>
    userState.hashCode;
}
