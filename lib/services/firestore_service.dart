import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:logger/logger.dart';
import '../data/models/user_model.dart';
import '../data/models/group_model.dart';
import '../data/models/contribution_model.dart';
import '../data/models/penalty_model.dart';
import '../data/models/payout_model.dart';
import '../domain/entities/user.dart';
import '../domain/entities/group.dart';
import '../domain/entities/contribution.dart';
import '../domain/entities/penalty.dart';
import '../domain/entities/payout.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  // Collection names
  static const String usersCollection = 'users';
  static const String groupsCollection = 'groups';
  static const String contributionsCollection = 'contributions';
  static const String penaltiesCollection = 'penalties';
  static const String payoutsCollection = 'payouts';
  static const String transactionsCollection = 'transactions';
  static const String walletsCollection = 'wallets';

  // ==================== USER OPERATIONS ====================

  /// Save user profile with proper error handling
  Future<void> saveUserProfile(User user, {String? phoneNumber}) async {
    try {
      _logger.i('Saving user profile: ${user.userId}');

      // Verify user is authenticated
      final currentUser = auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception(
          'User not authenticated. Cannot save profile to Firestore. '
          'Make sure user is signed in before saving.',
        );
      }

      if (currentUser.uid != user.userId) {
        _logger.w('Warning: Authenticated user UID does not match user profile UID');
      }

      // Add a small delay to ensure auth state is propagated to Firestore
      await Future.delayed(const Duration(milliseconds: 500));

      // Prepare data with null safety
      final userData = {
        'user_id': user.userId,
        'full_name': user.fullName.isEmpty ? 'User' : user.fullName,
        'phone_number': phoneNumber ?? user.phoneNumber,
        'smega_number': user.smegaNumber,
        'email': user.email.isEmpty ? currentUser.email : user.email,
        'registered_date': user.registeredDate,
        'is_kyc_verified': user.isKycVerified,
        'profile_image_url': user.profileImageUrl,
        'status': user.status.name,
        'updated_at': FieldValue.serverTimestamp(),
      };

      _logger.i('Writing to Firestore: users/${user.userId}');

      await _firestore
          .collection(usersCollection)
          .doc(user.userId)
          .set(userData, SetOptions(merge: true))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Firestore save operation timed out'),
          );

      _logger.i('User profile saved successfully');
    } on FirebaseException catch (e) {
      _logger.e(
        'Firestore error saving user profile: ${e.code} - ${e.message}',
      );
      String friendlyError = 'Failed to save profile';
      if (e.code == 'permission-denied') {
        friendlyError = 'Permission denied: Please check Firestore rules';
      } else if (e.code == 'unavailable') {
        friendlyError = 'Firestore unavailable: Please try again later';
      } else if (e.code == 'not-found') {
        friendlyError = 'Database not found: Please configure Firestore';
      }
      throw Exception(friendlyError);
    } catch (e) {
      _logger.e('Save user profile error: $e');
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }

  /// Get user profile with proper error handling
  Future<User?> getUserProfile(String userId) async {
    try {
      if (userId.isEmpty) {
        _logger.w('getUserProfile called with empty userId');
        return null;
      }

      _logger.i('Fetching user profile: $userId');

      final doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get()
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw Exception('Firestore fetch operation timed out'),
          );

      if (!doc.exists) {
        _logger.w('User profile not found: $userId');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        _logger.w('User document exists but has no data: $userId');
        return null;
      }

      try {
        final userModel = UserModel.fromJson(data);
        _logger.i('User profile fetched successfully');
        return userModel.toDomain();
      } catch (parseError) {
        _logger.e('Error parsing user data: $parseError');
        throw Exception('Failed to parse user data: $parseError');
      }
    } on FirebaseException catch (e) {
      _logger.e('Firestore error getting user profile: ${e.code} - ${e.message}');
      throw Exception('Failed to fetch user profile: ${e.message}');
    } catch (e) {
      _logger.e('Get user profile error: $e');
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  /// Update user's phone number
  Future<void> updateUserPhoneNumber({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      _logger.i('Updating phone number for user: $userId');

      await _firestore
          .collection(usersCollection)
          .doc(userId)
          .update({
            'phone_number': phoneNumber,
            'is_phone_verified': true,
            'updated_at': FieldValue.serverTimestamp(),
          });

      _logger.i('Phone number updated successfully');
    } catch (e) {
      _logger.e('Update phone number error: $e');
      rethrow;
    }
  }

  /// Check if phone number exists
  Future<bool> phoneNumberExists(String phoneNumber) async {
    try {
      _logger.i('Checking if phone number exists: $phoneNumber');

      final query = await _firestore
          .collection(usersCollection)
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      _logger.e('Check phone number error: $e');
      rethrow;
    }
  }

  /// Get user by phone number
  Future<User?> getUserByPhone(String phoneNumber) async {
    try {
      _logger.i('Getting user by phone: $phoneNumber');

      final query = await _firestore
          .collection(usersCollection)
          .where('phone_number', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _logger.w('User not found with phone: $phoneNumber');
        return null;
      }

      final userModel = UserModel.fromJson(query.docs.first.data());
      _logger.i('User found with phone: $phoneNumber');
      return userModel.toDomain();
    } catch (e) {
      _logger.e('Get user by phone error: $e');
      rethrow;
    }
  }

  // ==================== GROUP OPERATIONS ====================

  /// Save group
  Future<void> saveGroup(Group group) async {
    try {
      _logger.i('Saving group: ${group.groupId}');

      final groupModel = GroupModel(
        groupId: group.groupId,
        groupName: group.groupName,
        adminId: group.adminId,
        tier: group.tier.name,
        maximumMembers: group.maximumMembers,
        walletId: group.walletId,
        inviteCode: group.inviteCode,
        createdDate: group.createdDate,
        currentBalance: group.currentBalance,
        currentMemberCount: group.currentMemberCount,
        memberIds: group.memberIds,
        status: group.status.name,
        groupDescription: group.groupDescription,
      );

      await _firestore
          .collection(groupsCollection)
          .doc(group.groupId)
          .set(groupModel.toJson());

      _logger.i('Group saved successfully');
    } catch (e) {
      _logger.e('Save group error: $e');
      rethrow;
    }
  }

  /// Get group by ID
  Future<Group?> getGroup(String groupId) async {
    try {
      _logger.i('Fetching group: $groupId');

      final doc = await _firestore
          .collection(groupsCollection)
          .doc(groupId)
          .get();

      if (!doc.exists) {
        _logger.w('Group not found: $groupId');
        return null;
      }

      final groupModel = GroupModel.fromJson(doc.data()!);
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Get group error: $e');
      rethrow;
    }
  }

  /// Get group by invite code
  Future<Group?> getGroupByInviteCode(String inviteCode) async {
    try {
      _logger.i('Fetching group by invite code: $inviteCode');

      final query = await _firestore
          .collection(groupsCollection)
          .where('invite_code', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        _logger.w('Group not found with invite code: $inviteCode');
        return null;
      }

      final groupModel = GroupModel.fromJson(query.docs.first.data());
      return groupModel.toDomain();
    } catch (e) {
      _logger.e('Get group by invite code error: $e');
      rethrow;
    }
  }

  /// Get user's groups
  Future<List<Group>> getUserGroups(String userId) async {
    try {
      _logger.i('Fetching groups for user: $userId');

      final query = await _firestore
          .collection(groupsCollection)
          .where('members', arrayContains: userId)
          .get();

      final groups = query.docs
          .map((doc) => GroupModel.fromJson(doc.data()).toDomain())
          .toList();

      _logger.i('Fetched ${groups.length} groups');
      return groups;
    } catch (e) {
      _logger.e('Get user groups error: $e');
      rethrow;
    }
  }

  /// Add member to group
  Future<void> addMemberToGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      _logger.i('Adding member $userId to group $groupId');

      await _firestore.collection(groupsCollection).doc(groupId).update({
        'members': FieldValue.arrayUnion([userId]),
        'current_member_count': FieldValue.increment(1),
      });

      _logger.i('Member added successfully');
    } catch (e) {
      _logger.e('Add member to group error: $e');
      rethrow;
    }
  }

  // ==================== CONTRIBUTION OPERATIONS ====================

  /// Save contribution
  Future<void> saveContribution(Contribution contribution) async {
    try {
      _logger.i('Saving contribution: ${contribution.contributionId}');

      final contributionModel = ContributionModel(
        contributionId: contribution.contributionId,
        groupId: contribution.groupId,
        userId: contribution.userId,
        amount: contribution.amount,
        status: contribution.status.name,
        dueDate: contribution.dueDate,
        paidAt: contribution.paidAt,
        reference: contribution.reference,
        penalty: contribution.penalty,
      );

      await _firestore
          .collection(contributionsCollection)
          .doc(contribution.contributionId)
          .set(contributionModel.toJson());

      _logger.i('Contribution saved successfully');
    } catch (e) {
      _logger.e('Save contribution error: $e');
      rethrow;
    }
  }

  /// Get contributions for group
  Future<List<Contribution>> getGroupContributions(String groupId) async {
    try {
      _logger.i('Fetching contributions for group: $groupId');

      final query = await _firestore
          .collection(contributionsCollection)
          .where('group_id', isEqualTo: groupId)
          .get();

      final contributions = query.docs
          .map((doc) => ContributionModel.fromJson(doc.data()).toDomain())
          .toList();

      return contributions;
    } catch (e) {
      _logger.e('Get group contributions error: $e');
      rethrow;
    }
  }

  /// Get user's contributions for a group
  Future<List<Contribution>> getUserContributions({
    required String groupId,
    required String userId,
  }) async {
    try {
      _logger.i('Fetching contributions for user: $userId in group: $groupId');

      final query = await _firestore
          .collection(contributionsCollection)
          .where('group_id', isEqualTo: groupId)
          .where('user_id', isEqualTo: userId)
          .get();

      final contributions = query.docs
          .map((doc) => ContributionModel.fromJson(doc.data()).toDomain())
          .toList();

      return contributions;
    } catch (e) {
      _logger.e('Get user contributions error: $e');
      rethrow;
    }
  }

  // ==================== PENALTY OPERATIONS ====================

  /// Save penalty
  Future<void> savePenalty(Penalty penalty) async {
    try {
      _logger.i('Saving penalty: ${penalty.penaltyId}');

      final penaltyModel = PenaltyModel(
        penaltyId: penalty.penaltyId,
        groupId: penalty.groupId,
        userId: penalty.userId,
        amount: penalty.amount,
        reason: penalty.reason,
        createdAt: penalty.createdAt,
        isPaid: penalty.isPaid,
        paidAt: penalty.paidAt,
      );

      await _firestore
          .collection(penaltiesCollection)
          .doc(penalty.penaltyId)
          .set(penaltyModel.toJson());

      _logger.i('Penalty saved successfully');
    } catch (e) {
      _logger.e('Save penalty error: $e');
      rethrow;
    }
  }

  /// Get user's penalties
  Future<List<Penalty>> getUserPenalties({
    required String groupId,
    required String userId,
  }) async {
    try {
      _logger.i('Fetching penalties for user: $userId in group: $groupId');

      final query = await _firestore
          .collection(penaltiesCollection)
          .where('group_id', isEqualTo: groupId)
          .where('user_id', isEqualTo: userId)
          .get();

      final penalties = query.docs
          .map((doc) => PenaltyModel.fromJson(doc.data()).toDomain())
          .toList();

      return penalties;
    } catch (e) {
      _logger.e('Get user penalties error: $e');
      rethrow;
    }
  }

  // ==================== PAYOUT OPERATIONS ====================

  /// Save payout
  Future<void> savePayout(Payout payout) async {
    try {
      _logger.i('Saving payout: ${payout.payoutId}');

      final payoutModel = PayoutModel(
        payoutId: payout.payoutId,
        groupId: payout.groupId,
        receiverId: payout.receiverId,
        amount: payout.amount,
        payoutOrder: payout.payoutOrder,
        status: payout.status.name,
        scheduledDate: payout.scheduledDate,
        completedDate: payout.completedDate,
        paymentReference: payout.paymentReference,
      );

      await _firestore
          .collection(payoutsCollection)
          .doc(payout.payoutId)
          .set(payoutModel.toJson());

      _logger.i('Payout saved successfully');
    } catch (e) {
      _logger.e('Save payout error: $e');
      rethrow;
    }
  }

  /// Get payouts for group
  Future<List<Payout>> getGroupPayouts(String groupId) async {
    try {
      _logger.i('Fetching payouts for group: $groupId');

      final query = await _firestore
          .collection(payoutsCollection)
          .where('group_id', isEqualTo: groupId)
          .orderBy('payout_order', descending: false)
          .get();

      final payouts = query.docs
          .map((doc) => PayoutModel.fromJson(doc.data()).toDomain())
          .toList();

      return payouts;
    } catch (e) {
      _logger.e('Get group payouts error: $e');
      rethrow;
    }
  }

  /// Get user's payout schedule
  Future<List<Payout>> getUserPayoutSchedule(String groupId, String userId) async {
    try {
      _logger.i(
          'Fetching payout schedule for user: $userId in group: $groupId');

      final query = await _firestore
          .collection(payoutsCollection)
          .where('group_id', isEqualTo: groupId)
          .where('receiver_id', isEqualTo: userId)
          .orderBy('payout_order', descending: false)
          .get();

      final payouts = query.docs
          .map((doc) => PayoutModel.fromJson(doc.data()).toDomain())
          .toList();

      return payouts;
    } catch (e) {
      _logger.e('Get user payout schedule error: $e');
      rethrow;
    }
  }
}
