import 'package:equatable/equatable.dart';

class Group extends Equatable {

  const Group({
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
    this.status = GroupStatus.active,
    this.groupDescription,
  });
  final String groupId;
  final String groupName;
  final String adminId;
  final GroupTier tier;
  final int maximumMembers;
  final String walletId;
  final String inviteCode;
  final DateTime createdDate;
  final double currentBalance;
  final int currentMemberCount;
  final List<String> memberIds;
  final GroupStatus status;
  final String? groupDescription;

  @override
  List<Object?> get props => [
    groupId,
    groupName,
    adminId,
    tier,
    maximumMembers,
    walletId,
    inviteCode,
    createdDate,
    currentBalance,
    currentMemberCount,
    memberIds,
    status,
    groupDescription,
  ];

  Group copyWith({
    String? groupId,
    String? groupName,
    String? adminId,
    GroupTier? tier,
    int? maximumMembers,
    String? walletId,
    String? inviteCode,
    DateTime? createdDate,
    double? currentBalance,
    int? currentMemberCount,
    List<String>? memberIds,
    GroupStatus? status,
    String? groupDescription,
  }) => Group(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      adminId: adminId ?? this.adminId,
      tier: tier ?? this.tier,
      maximumMembers: maximumMembers ?? this.maximumMembers,
      walletId: walletId ?? this.walletId,
      inviteCode: inviteCode ?? this.inviteCode,
      createdDate: createdDate ?? this.createdDate,
      currentBalance: currentBalance ?? this.currentBalance,
      currentMemberCount: currentMemberCount ?? this.currentMemberCount,
      memberIds: memberIds ?? this.memberIds,
      status: status ?? this.status,
      groupDescription: groupDescription ?? this.groupDescription,
    );
}

enum GroupTier { tier1, tier2, tier3 }

enum GroupStatus { active, inactive, suspended }

extension GroupTierExtension on GroupTier {
  int get maxMembers => switch (this) {
      GroupTier.tier1 => 50,
      GroupTier.tier2 => 200,
      GroupTier.tier3 => 1000,
    };

  double get subscriptionPrice => switch (this) {
      GroupTier.tier1 => 50.0,
      GroupTier.tier2 => 150.0,
      GroupTier.tier3 => 500.0,
    };

  String get displayName => switch (this) {
      GroupTier.tier1 => 'Basic (P50)',
      GroupTier.tier2 => 'Standard (P150)',
      GroupTier.tier3 => 'Premium (P500)',
    };
}
