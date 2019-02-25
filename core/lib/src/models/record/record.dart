import 'package:json_annotation/json_annotation.dart';
part 'record.g.dart';

@JsonSerializable()
class Record {
  Record({
    this.currency,
    this.amount,
    this.title,
    this.description,
    this.city,
    this.zip,
    this.beneficiaryId,
    this.userId,
    this.link,
    this.photos
  });

  String currency;
  double amount;
  String title;
  String description;
  String city;
  String zip;
  String beneficiaryId;
  String userId;
  String link;
  List<String> photos;

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);

  Map<String, dynamic> toJson() => _$RecordToJson(this);

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is Record &&
        runtimeType == other.runtimeType &&
        currency == other.currency &&
        amount == other.amount &&
        title == other.title &&
        description == other.description &&
        city == other.city &&
        zip == other.zip &&
        beneficiaryId == other.beneficiaryId &&
        userId == other.userId &&
        link == other.link &&
        photos == other.photos;
  }

  @override
  int get hashCode =>
    currency.hashCode ^
    amount.hashCode ^
    title.hashCode ^
    description.hashCode ^
    city.hashCode ^
    zip.hashCode ^
    beneficiaryId.hashCode ^
    userId.hashCode ^
    link.hashCode ^
    photos.hashCode;
}