import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/contribution.dart';

part 'contribution_model.g.dart';

@JsonSerializable()
class ContributionModel {

  ContributionModel({
    required this.contributionId,
    required this.groupId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.reference,
    this.penalty,
  });

  factory ContributionModel.fromJson(Map<String, dynamic> json) =>
      _$ContributionModelFromJson(json);

  factory ContributionModel.fromDomain(Contribution domain) => ContributionModel(
      contributionId: domain.contributionId,
      groupId: domain.groupId,
      userId: domain.userId,
      amount: domain.amount,
      status: domain.status.name,
      dueDate: domain.dueDate,
      paidAt: domain.paidAt,
      reference: domain.reference,
      penalty: domain.penalty,
    );
  @JsonKey(name: 'contribution_id')
  final String contributionId;

  @JsonKey(name: 'group_id')
  final String groupId;

  @JsonKey(name: 'user_id')
  final String userId;

  final double amount;

  final String status;

  @JsonKey(name: 'due_date')
  final DateTime dueDate;

  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  final String? reference;

  final double? penalty;

  Map<String, dynamic> toJson() => _$ContributionModelToJson(this);

  Contribution toDomain() => Contribution(
      contributionId: contributionId,
      groupId: groupId,
      userId: userId,
      amount: amount,
      status: _stringToContributionStatus(status),
      dueDate: dueDate,
      paidAt: paidAt,
      reference: reference,
      penalty: penalty,
    );
}

ContributionStatus _stringToContributionStatus(String status) => ContributionStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => ContributionStatus.pending,
  );
