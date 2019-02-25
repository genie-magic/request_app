import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';

@JsonSerializable()
class User {
  String userName;
  String uuid;

  User({
    this.userName,
    this.uuid
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  bool operator ==(other) {
    return identical(this, other) ||
    other is User &&
      runtimeType == other.runtimeType &&
      userName == userName &&
      uuid == uuid;
  }

  @override
  // TODO: implement hashCode
  int get hashCode =>
      userName.hashCode ^
      uuid.hashCode;
}