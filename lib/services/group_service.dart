import '../core/constants/app_constants.dart';
import '../core/utils/api_service.dart';
import '../data/models/group_model.dart';
import '../domain/entities/group.dart';
import '../domain/entities/group_member.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class GroupService {

  GroupService({required ApiService apiService}) : _apiService = apiService;
  final ApiService _apiService;
  final Logger _logger = Logger();
  static const _uuid = Uuid();

  /// Create a new group
  Future<Group> createGroup({
    required String groupName,
    required String adminId,
    required GroupTier tier,
    String? groupDescription,
  }) async {
    try {
      _logger.i('Creating group: $groupName');
      
      final inviteCode = _generateInviteCode();
      final walletId = _uuid.v4();

      final data = {
        'group_name': groupName,
        'admin_id': adminId,
        'tier': tier.name,
        'invite_code': inviteCode,
        'wallet_id': walletId,
        'group_description': groupDescription,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.createGroupEndpoint,
        data: data,
      );

      final groupModel = GroupModel.fromJson(response);
      _logger.i('Group created: ${groupModel.groupId}');
      
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Create group error: $e');
      rethrow;
    }
  }

  /// Join an existing group using invite code
  Future<Group> joinGroup({
    required String userId,
    required String inviteCode,
  }) async {
    try {
      _logger.i('Joining group with code: $inviteCode');
      
      final data = {
        'user_id': userId,
        'invite_code': inviteCode,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.joinGroupEndpoint,
        data: data,
      );

      final groupModel = GroupModel.fromJson(response);
      _logger.i('Joined group: ${groupModel.groupId}');
      
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Join group error: $e');
      rethrow;
    }
  }

  /// Get all groups for current user
  Future<List<Group>> getUserGroups({
    required String userId,
    int page = 1,
  }) async {
    try {
      _logger.i('Fetching groups for user: $userId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.getGroupsEndpoint,
        queryParameters: {
          'user_id': userId,
          'page': page,
          'limit': AppConstants.pageSize,
        },
      );

      final groups = response['groups'] as List;
      final groupList = groups
          .map((g) => GroupModel.fromJson(g as Map<String, dynamic>).toDomain())
          .toList();

      _logger.i('Fetched ${groupList.length} groups');
      return groupList;
    } catch (e) {
      _logger.e('Get user groups error: $e');
      rethrow;
    }
  }

  /// Get specific group details
  Future<Group> getGroup({required String groupId}) async {
    try {
      _logger.i('Fetching group: $groupId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        '${AppConstants.getGroupEndpoint}/$groupId',
      );

      final groupModel = GroupModel.fromJson(response);
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Get group error: $e');
      rethrow;
    }
  }

  /// Get group members
  Future<List<GroupMember>> getGroupMembers({
    required String groupId,
    int page = 1,
  }) async {
    try {
      _logger.i('Fetching members for group: $groupId');
      
      final endpoint = AppConstants.getGroupMembersEndpoint
          .replaceAll('{groupId}', groupId);
      
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {
          'page': page,
          'limit': AppConstants.pageSize,
        },
      );

      final members = response['members'] as List;
      final memberList = members.map((m) {
        final memberData = m as Map<String, dynamic>;
        return GroupMember(
          memberId: memberData['member_id'],
          groupId: memberData['group_id'],
          userId: memberData['user_id'],
          userName: memberData['user_name'],
          joinedDate: DateTime.parse(memberData['joined_date']),
          totalContributions: memberData['total_contributions'],
          totalAmount: (memberData['total_amount'] as num).toDouble(),
          role: _stringToMemberRole(memberData['role']),
          status: _stringToMemberStatus(memberData['status']),
        );
      }).toList();

      _logger.i('Fetched ${memberList.length} members');
      return memberList;
    } catch (e) {
      _logger.e('Get group members error: $e');
      rethrow;
    }
  }

  /// Update group details
  Future<Group> updateGroup({
    required String groupId,
    String? groupName,
    String? groupDescription,
  }) async {
    try {
      _logger.i('Updating group: $groupId');
      
      final data = {
        if (groupName != null) 'group_name': groupName,
        if (groupDescription != null) 'group_description': groupDescription,
      };

      final response = await _apiService.put<Map<String, dynamic>>(
        '${AppConstants.getGroupEndpoint}/$groupId',
        data: data,
      );

      final groupModel = GroupModel.fromJson(response);
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Update group error: $e');
      rethrow;
    }
  }

  /// Generate a unique invite code
  String _generateInviteCode() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    for (int i = 0; i < 8; i++) {
      buffer.write(chars[(DateTime.now().microsecond + i) % chars.length]);
    }
    return buffer.toString();
  }
}

MemberRole _stringToMemberRole(String role) => MemberRole.values.firstWhere(
    (e) => e.name == role,
    orElse: () => MemberRole.regular,
  );

MemberStatus _stringToMemberStatus(String status) => MemberStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => MemberStatus.active,
  );
