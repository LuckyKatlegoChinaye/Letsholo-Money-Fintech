// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
      groupId: json['group_id'] as String,
      groupName: json['group_name'] as String,
      adminId: json['admin_id'] as String,
      tier: json['tier'] as String,
      maximumMembers: (json['maximum_members'] as num).toInt(),
      walletId: json['wallet_id'] as String,
      inviteCode: json['invite_code'] as String,
      createdDate: DateTime.parse(json['created_date'] as String),
      currentBalance: (json['current_balance'] as num).toDouble(),
      currentMemberCount: (json['current_member_count'] as num).toInt(),
      status: json['status'] as String? ?? 'active',
      groupDescription: json['group_description'] as String?,
    );

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{
      'group_id': instance.groupId,
      'group_name': instance.groupName,
      'admin_id': instance.adminId,
      'tier': instance.tier,
      'maximum_members': instance.maximumMembers,
      'wallet_id': instance.walletId,
      'invite_code': instance.inviteCode,
      'created_date': instance.createdDate.toIso8601String(),
      'current_balance': instance.currentBalance,
      'current_member_count': instance.currentMemberCount,
      'status': instance.status,
      'group_description': instance.groupDescription,
    };
