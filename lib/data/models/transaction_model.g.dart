// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      groupId: json['group_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reference: json['reference'] as String?,
      latePaymentFee: (json['late_payment_fee'] as num?)?.toDouble(),
      platformFeeDeducted: (json['platform_fee_deducted'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'transaction_id': instance.transactionId,
      'user_id': instance.userId,
      'group_id': instance.groupId,
      'amount': instance.amount,
      'type': instance.type,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'reference': instance.reference,
      'late_payment_fee': instance.latePaymentFee,
      'platform_fee_deducted': instance.platformFeeDeducted,
      'description': instance.description,
    };
