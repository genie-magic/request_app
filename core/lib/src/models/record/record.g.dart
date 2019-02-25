// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Record _$RecordFromJson(Map<String, dynamic> json) {
  return Record(
      currency: json['currency'] as String,
      amount: (json['amount'] as num)?.toDouble(),
      title: json['title'] as String,
      description: json['description'] as String,
      city: json['city'] as String,
      zip: json['zip'] as String,
      beneficiaryId: json['beneficiaryId'] as String,
      userId: json['userId'] as String,
      link: json['link'] as String,
      photos: (json['photos'] as List)?.map((e) => e as String)?.toList());
}

Map<String, dynamic> _$RecordToJson(Record instance) => <String, dynamic>{
      'currency': instance.currency,
      'amount': instance.amount,
      'title': instance.title,
      'description': instance.description,
      'city': instance.city,
      'zip': instance.zip,
      'beneficiaryId': instance.beneficiaryId,
      'userId': instance.userId,
      'link': instance.link,
      'photos': instance.photos
    };
