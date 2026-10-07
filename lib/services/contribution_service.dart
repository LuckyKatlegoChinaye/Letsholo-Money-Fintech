import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../core/constants/app_constants.dart';
import '../domain/entities/contribution.dart';
import '../domain/entities/penalty.dart';
import './firestore_service.dart';

class ContributionService {

  ContributionService({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();
  static const _uuid = Uuid();

  /// Create a contribution for a user in a group
  Future<Contribution> createContribution({
    required String groupId,
    required String userId,
    required double amount,
    required DateTime dueDate,
  }) async {
    try {
      _logger.i(
          'Creating contribution for user $userId in group $groupId, amount: $amount');

      final contribution = Contribution(
        contributionId: _uuid.v4(),
        groupId: groupId,
        userId: userId,
        amount: amount,
        status: ContributionStatus.pending,
        dueDate: dueDate,
      );

      await _firestoreService.saveContribution(contribution);
      _logger.i('Contribution created: ${contribution.contributionId}');

      return contribution;
    } catch (e) {
      _logger.e('Create contribution error: $e');
      rethrow;
    }
  }

  /// Mark contribution as paid
  Future<Contribution> markContributionAsPaid({
    required String groupId,
    required String userId,
    required String contributionId,
    required String reference,
  }) async {
    try {
      _logger.i('Marking contribution $contributionId as paid');

      // Get existing contribution
      final contributions = await _firestoreService.getUserContributions(
        groupId: groupId,
        userId: userId,
      );

      final contribution = contributions.firstWhere(
        (c) => c.contributionId == contributionId,
        orElse: () => throw Exception('Contribution not found'),
      );

      final paidContribution = contribution.copyWith(
        status: ContributionStatus.paid,
        paidAt: DateTime.now(),
        reference: reference,
        penalty: null, // Clear any penalties
      );

      await _firestoreService.saveContribution(paidContribution);
      _logger.i('Contribution marked as paid');

      return paidContribution;
    } catch (e) {
      _logger.e('Mark contribution as paid error: $e');
      rethrow;
    }
  }

  /// Calculate and apply penalty for overdue contribution
  Future<Penalty> applyLatePenalty({
    required String groupId,
    required String userId,
    required String contributionId,
  }) async {
    try {
      _logger.i('Applying late penalty for contribution $contributionId');

      // Get contribution
      final contributions = await _firestoreService.getUserContributions(
        groupId: groupId,
        userId: userId,
      );

      final contribution = contributions.firstWhere(
        (c) => c.contributionId == contributionId,
        orElse: () => throw Exception('Contribution not found'),
      );

      if (contribution.isPaid) {
        throw Exception('Cannot apply penalty to paid contribution');
      }

      // Calculate penalty based on amount
      final penaltyAmount = contribution.amount *
          (AppConstants.platformPenaltyPercentage / 100);

      final penalty = Penalty(
        penaltyId: _uuid.v4(),
        groupId: groupId,
        userId: userId,
        amount: penaltyAmount,
        reason: 'Late payment penalty for contribution due ${contribution.dueDate}',
        createdAt: DateTime.now(),
      );

      await _firestoreService.savePenalty(penalty);

      // Update contribution with penalty
      final updatedContribution = contribution.copyWith(
        penalty: penaltyAmount,
        status: ContributionStatus.overdue,
      );

      await _firestoreService.saveContribution(updatedContribution);

      _logger.i('Late penalty applied: ${penalty.penaltyId}');

      return penalty;
    } catch (e) {
      _logger.e('Apply late penalty error: $e');
      rethrow;
    }
  }

  /// Get contribution status summary for a group
  Future<Map<String, dynamic>> getGroupContributionSummary(
      String groupId) async {
    try {
      _logger.i('Getting contribution summary for group $groupId');

      final contributions =
          await _firestoreService.getGroupContributions(groupId);

      int paidCount = 0;
      int overdueCount = 0;
      int pendingCount = 0;
      double totalCollected = 0;
      double totalDue = 0;
      double totalPenalties = 0;

      for (final contribution in contributions) {
        if (contribution.isPaid) {
          paidCount++;
          totalCollected += contribution.amount;
        } else if (contribution.isOverdue) {
          overdueCount++;
          totalDue += contribution.amount;
          if (contribution.penalty != null) {
            totalPenalties += contribution.penalty!;
          }
        } else {
          pendingCount++;
          totalDue += contribution.amount;
        }
      }

      final summary = {
        'totalContributions': contributions.length,
        'paidCount': paidCount,
        'overdueCount': overdueCount,
        'pendingCount': pendingCount,
        'totalCollected': totalCollected,
        'totalDue': totalDue,
        'totalPenalties': totalPenalties,
        'completionPercentage':
            contributions.isEmpty ? 0 : (paidCount / contributions.length * 100),
      };

      _logger.i('Contribution summary: $summary');

      return summary;
    } catch (e) {
      _logger.e('Get contribution summary error: $e');
      rethrow;
    }
  }

  /// Check for overdue contributions and apply penalties
  Future<List<Penalty>> processOverdueContributions(String groupId) async {
    try {
      _logger.i('Processing overdue contributions for group $groupId');

      final contributions =
          await _firestoreService.getGroupContributions(groupId);
      final now = DateTime.now();
      final appliedPenalties = <Penalty>[];

      for (final contribution in contributions) {
        if (!contribution.isPaid &&
            now.isAfter(contribution.dueDate) &&
            contribution.penalty == null) {
          try {
            final penalty = await applyLatePenalty(
              groupId: groupId,
              userId: contribution.userId,
              contributionId: contribution.contributionId,
            );
            appliedPenalties.add(penalty);
          } catch (e) {
            _logger.e('Error applying penalty: $e');
          }
        }
      }

      _logger.i('Applied ${appliedPenalties.length} penalties');

      return appliedPenalties;
    } catch (e) {
      _logger.e('Process overdue contributions error: $e');
      rethrow;
    }
  }

  /// Get total contribution amount for a user in a group
  Future<double> getUserTotalContributions({
    required String groupId,
    required String userId,
  }) async {
    try {
      final contributions = await _firestoreService.getUserContributions(
        groupId: groupId,
        userId: userId,
      );

      double total = 0;
      for (final contribution in contributions) {
        if (contribution.isPaid) {
          total += contribution.amount;
          if (contribution.penalty != null) {
            total += contribution.penalty!;
          }
        }
      }

      return total;
    } catch (e) {
      _logger.e('Get user total contributions error: $e');
      rethrow;
    }
  }

  /// Get pending contributions for a user
  Future<List<Contribution>> getUserPendingContributions({
    required String groupId,
    required String userId,
  }) async {
    try {
      final contributions = await _firestoreService.getUserContributions(
        groupId: groupId,
        userId: userId,
      );

      return contributions
          .where((c) => !c.isPaid)
          .toList();
    } catch (e) {
      _logger.e('Get pending contributions error: $e');
      rethrow;
    }
  }
}
