import 'package:core/src/models/record/record.dart';

class AddModeAction {

}

class EditModeAction {
  EditModeAction(
      this.record,
      this.editRecordID
      );

  final Record record;
  final String editRecordID;
}