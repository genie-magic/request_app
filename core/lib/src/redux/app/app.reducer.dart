import 'package:core/src/redux/user/user.reducers.dart';
import 'package:core/src/redux/app/app.state.dart';

AppState appReducer(AppState state, dynamic action) {
  return new AppState(
      userState: userReducer(state.userState, action)
  );
}