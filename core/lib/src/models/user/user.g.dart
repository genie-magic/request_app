// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
      userName: json['userName'] as String, uuid: json['uuid'] as String);
}

Map<String, dynamic> _$UserToJson(User instance) =>
    <String, dynamic>{'userName': instance.userName, 'uuid': instance.uuid};
