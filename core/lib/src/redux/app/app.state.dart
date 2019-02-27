import 'package:core/src/redux/user/user.state.dart';
import 'package:core/src/redux/record_request/record_request.state.dart';
import 'package:meta/meta.dart';

@immutable
class AppState {
  AppState({
    @required this.userState,
    @required this.recordRequestState
  });

  final UserState userState;
  final RecordRequestState recordRequestState;

  factory AppState.initial() {
    return AppState(
      userState: UserState.initial(),
      recordRequestState: RecordRequestState.initial()
    );
  }

  AppState copyWith({
    AppState userState
  }) {
    return AppState(
      userState: userState ?? this.userState,
      recordRequestState: recordRequestState ?? this.recordRequestState
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is AppState &&
        runtimeType == other.runtimeType &&
        userState == other.userState &&
        recordRequestState == other.recordRequestState;
  }

  @override
  int get hashCode =>
    userState.hashCode ^
    recordRequestState.hashCode;
}
