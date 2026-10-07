// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionModel _$ContributionModelFromJson(Map<String, dynamic> json) =>
    ContributionModel(
      contributionId: json['contribution_id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      reference: json['reference'] as String?,
      penalty: (json['penalty'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ContributionModelToJson(ContributionModel instance) =>
    <String, dynamic>{
      'contribution_id': instance.contributionId,
      'group_id': instance.groupId,
      'user_id': instance.userId,
      'amount': instance.amount,
      'status': instance.status,
      'due_date': instance.dueDate.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'reference': instance.reference,
      'penalty': instance.penalty,
    };
