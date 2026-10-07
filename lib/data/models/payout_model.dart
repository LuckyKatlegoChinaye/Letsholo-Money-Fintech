import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payout.dart';

part 'payout_model.g.dart';

@JsonSerializable()
class PayoutModel {

  PayoutModel({
    required this.payoutId,
    required this.groupId,
    required this.receiverId,
    required this.amount,
    required this.payoutOrder,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    this.paymentReference,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) =>
      _$PayoutModelFromJson(json);

  factory PayoutModel.fromDomain(Payout domain) => PayoutModel(
      payoutId: domain.payoutId,
      groupId: domain.groupId,
      receiverId: domain.receiverId,
      amount: domain.amount,
      payoutOrder: domain.payoutOrder,
      status: domain.status.name,
      scheduledDate: domain.scheduledDate,
      completedDate: domain.completedDate,
      paymentReference: domain.paymentReference,
    );
  @JsonKey(name: 'payout_id')
  final String payoutId;

  @JsonKey(name: 'group_id')
  final String groupId;

  @JsonKey(name: 'receiver_id')
  final String receiverId;

  final double amount;

  @JsonKey(name: 'payout_order')
  final int payoutOrder;

  final String status;

  @JsonKey(name: 'scheduled_date')
  final DateTime scheduledDate;

  @JsonKey(name: 'completed_date')
  final DateTime? completedDate;

  @JsonKey(name: 'payment_reference')
  final String? paymentReference;

  Map<String, dynamic> toJson() => _$PayoutModelToJson(this);

  Payout toDomain() => Payout(
      payoutId: payoutId,
      groupId: groupId,
      receiverId: receiverId,
      amount: amount,
      payoutOrder: payoutOrder,
      status: _stringToPayoutStatus(status),
      scheduledDate: scheduledDate,
      completedDate: completedDate,
      paymentReference: paymentReference,
    );
}

PayoutStatus _stringToPayoutStatus(String status) => PayoutStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => PayoutStatus.scheduled,
  );
