import 'package:json_annotation/json_annotation.dart';
part 'beneficiary.g.dart';

@JsonSerializable()
class Beneficiary {
  Beneficiary({
    this.id,
    this.value
  });

  String id;
  String value;

  factory Beneficiary.fromJson(Map<String, dynamic> json) => _$BeneficiaryFromJson(json);

  Map<String, dynamic> toJson() => _$BeneficiaryToJson(this);

  @override
  bool operator ==(other) {
    return identical(this, other) ||
      other is Beneficiary &&
        runtimeType == other.runtimeType &&
        id == other.id &&
        value == other.value;
  }

  @override
  int get hashCode =>
    id.hashCode ^
    value.hashCode;
}