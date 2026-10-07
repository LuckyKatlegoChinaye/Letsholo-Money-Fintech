import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/penalty.dart';

part 'penalty_model.g.dart';

@JsonSerializable()
class PenaltyModel {

  PenaltyModel({
    required this.penaltyId,
    required this.groupId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.createdAt,
    required this.isPaid,
    this.paidAt,
  });

  factory PenaltyModel.fromJson(Map<String, dynamic> json) =>
      _$PenaltyModelFromJson(json);

  factory PenaltyModel.fromDomain(Penalty domain) => PenaltyModel(
      penaltyId: domain.penaltyId,
      groupId: domain.groupId,
      userId: domain.userId,
      amount: domain.amount,
      reason: domain.reason,
      createdAt: domain.createdAt,
      isPaid: domain.isPaid,
      paidAt: domain.paidAt,
    );
  @JsonKey(name: 'penalty_id')
  final String penaltyId;

  @JsonKey(name: 'group_id')
  final String groupId;

  @JsonKey(name: 'user_id')
  final String userId;

  final double amount;

  final String reason;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'is_paid')
  final bool isPaid;

  @JsonKey(name: 'paid_at')
  final DateTime? paidAt;

  Map<String, dynamic> toJson() => _$PenaltyModelToJson(this);

  Penalty toDomain() => Penalty(
      penaltyId: penaltyId,
      groupId: groupId,
      userId: userId,
      amount: amount,
      reason: reason,
      createdAt: createdAt,
      isPaid: isPaid,
      paidAt: paidAt,
    );
}
