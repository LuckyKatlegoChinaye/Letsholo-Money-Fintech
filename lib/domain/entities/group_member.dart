import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {

  const GroupMember({
    required this.memberId,
    required this.groupId,
    required this.userId,
    required this.userName,
    required this.joinedDate,
    required this.totalContributions,
    required this.totalAmount,
    this.role = MemberRole.regular,
    this.status = MemberStatus.active,
  });
  final String memberId;
  final String groupId;
  final String userId;
  final String userName;
  final DateTime joinedDate;
  final int totalContributions;
  final double totalAmount;
  final MemberRole role;
  final MemberStatus status;

  @override
  List<Object?> get props => [
    memberId,
    groupId,
    userId,
    userName,
    joinedDate,
    totalContributions,
    totalAmount,
    role,
    status,
  ];

  GroupMember copyWith({
    String? memberId,
    String? groupId,
    String? userId,
    String? userName,
    DateTime? joinedDate,
    int? totalContributions,
    double? totalAmount,
    MemberRole? role,
    MemberStatus? status,
  }) => GroupMember(
      memberId: memberId ?? this.memberId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      joinedDate: joinedDate ?? this.joinedDate,
      totalContributions: totalContributions ?? this.totalContributions,
      totalAmount: totalAmount ?? this.totalAmount,
      role: role ?? this.role,
      status: status ?? this.status,
    );
}

enum MemberRole { admin, treasurer, regular }

enum MemberStatus { active, inactive, suspended }
