import 'package:core/src/models/record/record.dart';
import 'package:meta/meta.dart';

@immutable
class RecordRequestState {
  RecordRequestState({
    @required this.bAddOrEdit,
    @required this.editRecordID,
    @required this.record
  });

  final bool bAddOrEdit;
  final String editRecordID;
  final Record record;

  factory RecordRequestState.initial() {
    return RecordRequestState(
      bAddOrEdit: true,
      editRecordID: '',
      record: null
    );
  }

  RecordRequestState copyWith({
    bool bAddOrEdit,
    String editRecordID,
    Record record
  }) {
    return RecordRequestState(
      bAddOrEdit: bAddOrEdit ?? this.bAddOrEdit,
      editRecordID: editRecordID ?? this.editRecordID,
      record: record ?? this.record
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is RecordRequestState &&
        runtimeType == other.runtimeType &&
        bAddOrEdit == other.bAddOrEdit &&
        editRecordID == other.editRecordID &&
        record == other.record;
  }

  @override
  int get hashCode =>
    bAddOrEdit.hashCode ^
    editRecordID.hashCode ^
    record.hashCode;
}