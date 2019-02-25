import 'package:core/src/redux/user/user.actions.dart';
import 'package:core/src/redux/user/user.state.dart';

UserState userReducer(UserState state, dynamic action) {
  if (action is LoginAction) {
    return state.copyWith(
      user: action.user
    );
  } else if (action is LogoutAction) {
    return state.copyWith(
      user: null
    );
  }

  return state;
}