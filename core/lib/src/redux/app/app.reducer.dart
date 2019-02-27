import 'package:core/src/redux/user/user.reducers.dart';
import 'package:core/src/redux/record_request/record_request.reducers.dart';
import 'package:core/src/redux/app/app.state.dart';

AppState appReducer(AppState state, dynamic action) {
  return new AppState(
    userState: userReducer(state.userState, action),
    recordRequestState: recordRequestReducer(state.recordRequestState, action)
  );
}