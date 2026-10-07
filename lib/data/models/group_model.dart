import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/group.dart';

part 'group_model.g.dart';

@JsonSerializable()
class GroupModel {

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.adminId,
    required this.tier,
    required this.maximumMembers,
    required this.walletId,
    required this.inviteCode,
    required this.createdDate,
    required this.currentBalance,
    required this.currentMemberCount,
    this.memberIds = const [],
    this.status = 'active',
    this.groupDescription,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    try {
      // Create the model first
      final model = _$GroupModelFromJson(json);
      
      // Safely cast memberIds from List<dynamic> to List<String>
      List<String> safeMembers = [];
      if (model.memberIds.isNotEmpty) {
        try {
          // Convert each element to String
          safeMembers = model.memberIds
              .map((id) => id.toString())
              .toList()
              .cast<String>();
        } catch (e) {
          // Fallback: safely convert all to strings
          safeMembers = model.memberIds
              .whereType<Object>()
              .map((id) => id.toString())
              .toList();
        }
      }

      // Return model with safety fixes applied
      return GroupModel(
        groupId: model.groupId,
        groupName: model.groupName,
        adminId: model.adminId,
        tier: model.tier,
        maximumMembers: model.maximumMembers,
        walletId: model.walletId,
        inviteCode: model.inviteCode,
        createdDate: model.createdDate,
        currentBalance: model.currentBalance,
        currentMemberCount: model.currentMemberCount,
        memberIds: safeMembers,
        status: model.status,
        groupDescription: model.groupDescription,
      );
    } catch (e) {
      throw Exception('Failed to parse GroupModel from JSON: $e');
    }
  }

  factory GroupModel.fromDomain(Group domain) => GroupModel(
      groupId: domain.groupId,
      groupName: domain.groupName,
      adminId: domain.adminId,
      tier: domain.tier.name,
      maximumMembers: domain.maximumMembers,
      walletId: domain.walletId,
      inviteCode: domain.inviteCode,
      createdDate: domain.createdDate,
      currentBalance: domain.currentBalance,
      currentMemberCount: domain.currentMemberCount,
      memberIds: domain.memberIds,
      status: domain.status.name,
      groupDescription: domain.groupDescription,
    );
  @JsonKey(name: 'group_id')
  final String groupId;
  
  @JsonKey(name: 'group_name')
  final String groupName;
  
  @JsonKey(name: 'admin_id')
  final String adminId;
  
  final String tier;
  
  @JsonKey(name: 'maximum_members')
  final int maximumMembers;
  
  @JsonKey(name: 'wallet_id')
  final String walletId;
  
  @JsonKey(name: 'invite_code')
  final String inviteCode;
  
  @JsonKey(name: 'created_date')
  final DateTime createdDate;
  
  @JsonKey(name: 'current_balance')
  final double currentBalance;
  
  @JsonKey(name: 'current_member_count')
  final int currentMemberCount;
  
  @JsonKey(name: 'member_ids', defaultValue: [])
  final List<String> memberIds;
  
  final String status;
  
  @JsonKey(name: 'group_description')
  final String? groupDescription;

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);

  Group toDomain() => Group(
      groupId: groupId,
      groupName: groupName,
      adminId: adminId,
      tier: _stringToGroupTier(tier),
      maximumMembers: maximumMembers,
      walletId: walletId,
      inviteCode: inviteCode,
      createdDate: createdDate,
      currentBalance: currentBalance,
      currentMemberCount: currentMemberCount,
      memberIds: memberIds,
      status: _stringToGroupStatus(status),
      groupDescription: groupDescription,
    );
}

GroupTier _stringToGroupTier(String tier) => GroupTier.values.firstWhere(
    (e) => e.name == tier,
    orElse: () => GroupTier.tier1,
  );

GroupStatus _stringToGroupStatus(String status) => GroupStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => GroupStatus.active,
  );
