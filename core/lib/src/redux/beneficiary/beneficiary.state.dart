import 'package:core/src/models/beneficiary/beneficiary.dart';
import 'package:core/src/models/loading_status/loading_status.dart';
import 'package:meta/meta.dart';

@immutable
class BeneficiaryState {
  BeneficiaryState({
    @required this.loadingStatus,
    @required this.beneficiaries
  });

  final LoadingStatus loadingStatus;
  final List<Beneficiary> beneficiaries;

  factory BeneficiaryState.initial() {
    return BeneficiaryState(
        loadingStatus: LoadingStatus.idle,
        beneficiaries: []
    );
  }

  BeneficiaryState copyWith({
    LoadingStatus loadingStatus,
    List<Beneficiary> beneficiaries
  }) {
    return BeneficiaryState(
        loadingStatus: loadingStatus ?? this.loadingStatus,
        beneficiaries: beneficiaries ?? this.beneficiaries
    );
  }

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        other is BeneficiaryState &&
            runtimeType == other.runtimeType &&
            beneficiaries == other.beneficiaries &&
            loadingStatus == other.loadingStatus;
  }

  @override
  int get hashCode =>
      loadingStatus.hashCode ^
      beneficiaries.hashCode;
}