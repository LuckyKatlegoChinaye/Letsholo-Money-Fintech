// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penalty_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PenaltyModel _$PenaltyModelFromJson(Map<String, dynamic> json) => PenaltyModel(
      penaltyId: json['penalty_id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isPaid: json['is_paid'] as bool,
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
    );

Map<String, dynamic> _$PenaltyModelToJson(PenaltyModel instance) =>
    <String, dynamic>{
      'penalty_id': instance.penaltyId,
      'group_id': instance.groupId,
      'user_id': instance.userId,
      'amount': instance.amount,
      'reason': instance.reason,
      'created_at': instance.createdAt.toIso8601String(),
      'is_paid': instance.isPaid,
      'paid_at': instance.paidAt?.toIso8601String(),
    };
