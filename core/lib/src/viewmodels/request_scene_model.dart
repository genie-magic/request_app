import 'package:redux/redux.dart';
import 'package:core/src/models/user/user.dart';
import 'package:core/src/models/record/record.dart';
import 'package:core/src/redux/app/app.state.dart';
import 'package:meta/meta.dart';

class RequestSceneModel {
  RequestSceneModel({
    @required this.loginUser,
    @required this.record,
    @required this.editRecordID,
    @required this.bAddOrEdit
  });

  final User loginUser;
  final Record record;
  final String editRecordID;
  final bool bAddOrEdit;

  static RequestSceneModel fromStore(
      Store<AppState> store,
  ){
    return RequestSceneModel(
      loginUser: store.state.userState.user,
      record: store.state.recordRequestState.record,
      editRecordID: store.state.recordRequestState.editRecordID,
      bAddOrEdit: store.state.recordRequestState.bAddOrEdit
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is RequestSceneModel &&
        runtimeType == other.runtimeType &&
        loginUser == other.loginUser &&
        record == other.record &&
        editRecordID == other.editRecordID &&
        bAddOrEdit == other.bAddOrEdit;
  }

  @override
  int get hashCode =>
    loginUser.hashCode ^
    record.hashCode ^
    editRecordID.hashCode ^
    bAddOrEdit.hashCode;
}