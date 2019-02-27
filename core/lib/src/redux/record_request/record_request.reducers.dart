import 'package:core/src/redux/record_request/record_request.actions.dart';
import 'package:core/src/redux/record_request/record_request.state.dart';

RecordRequestState recordRequestReducer(RecordRequestState state, dynamic action) {
  if (action is AddModeAction) {
    print('add mode action is dispatched');
    return state.copyWith(
      bAddOrEdit: true,
      record: null,
      editRecordID: ''
    );
  } else if (action is EditModeAction) {
    return state.copyWith(
      bAddOrEdit: false,
      record: action.record,
      editRecordID: action.editRecordID
    );
  }

  return state;
}