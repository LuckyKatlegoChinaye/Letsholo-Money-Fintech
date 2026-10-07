// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayoutModel _$PayoutModelFromJson(Map<String, dynamic> json) => PayoutModel(
      payoutId: json['payout_id'] as String,
      groupId: json['group_id'] as String,
      receiverId: json['receiver_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      payoutOrder: (json['payout_order'] as num).toInt(),
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      completedDate: json['completed_date'] == null
          ? null
          : DateTime.parse(json['completed_date'] as String),
      paymentReference: json['payment_reference'] as String?,
    );

Map<String, dynamic> _$PayoutModelToJson(PayoutModel instance) =>
    <String, dynamic>{
      'payout_id': instance.payoutId,
      'group_id': instance.groupId,
      'receiver_id': instance.receiverId,
      'amount': instance.amount,
      'payout_order': instance.payoutOrder,
      'status': instance.status,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'completed_date': instance.completedDate?.toIso8601String(),
      'payment_reference': instance.paymentReference,
    };
