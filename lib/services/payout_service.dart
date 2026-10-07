import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';
import '../domain/entities/payout.dart';
import './firestore_service.dart';

class PayoutService {

  PayoutService({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;
  final FirestoreService _firestoreService;
  final Logger _logger = Logger();
  static const _uuid = Uuid();

  /// Create payout schedule for a group
  Future<List<Payout>> createPayoutSchedule({
    required String groupId,
    required List<String> memberIds,
    required double payoutAmount,
  }) async {
    try {
      _logger.i(
          'Creating payout schedule for group $groupId with ${memberIds.length} members');

      final payouts = <Payout>[];
      final startDate = DateTime.now().add(const Duration(days: 30));

      for (int i = 0; i < memberIds.length; i++) {
        final payout = Payout(
          payoutId: _uuid.v4(),
          groupId: groupId,
          receiverId: memberIds[i],
          amount: payoutAmount,
          payoutOrder: i + 1,
          status: PayoutStatus.scheduled,
          scheduledDate:
              startDate.add(Duration(days: 30 * i)),
        );

        await _firestoreService.savePayout(payout);
        payouts.add(payout);
      }

      _logger.i('Payout schedule created with ${payouts.length} payouts');

      return payouts;
    } catch (e) {
      _logger.e('Create payout schedule error: $e');
      rethrow;
    }
  }

  /// Get next payout in rotation
  Future<Payout?> getNextPayout(String groupId) async {
    try {
      _logger.i('Getting next payout for group $groupId');

      final payouts = await _firestoreService.getGroupPayouts(groupId);

      // Find the first pending or scheduled payout
      final nextPayout = payouts.firstWhere(
        (p) =>
            p.status == PayoutStatus.pending ||
            p.status == PayoutStatus.scheduled,
        orElse: () => throw Exception('No pending payouts found'),
      );

      _logger.i('Next payout: ${nextPayout.payoutId}');

      return nextPayout;
    } catch (e) {
      _logger.e('Get next payout error: $e');
      return null;
    }
  }

  /// Trigger payout for a specific member
  Future<Payout> triggerPayout({
    required String groupId,
    required String payoutId,
    required String paymentReference,
  }) async {
    try {
      _logger.i(
          'Triggering payout $payoutId for group $groupId with reference $paymentReference');

      final payouts = await _firestoreService.getGroupPayouts(groupId);
      final payout = payouts.firstWhere(
        (p) => p.payoutId == payoutId,
        orElse: () => throw Exception('Payout not found'),
      );

      if (payout.isCompleted) {
        throw Exception('Payout already completed');
      }

      final completedPayout = payout.copyWith(
        status: PayoutStatus.completed,
        completedDate: DateTime.now(),
        paymentReference: paymentReference,
      );

      await _firestoreService.savePayout(completedPayout);

      _logger.i('Payout triggered and marked as completed');

      return completedPayout;
    } catch (e) {
      _logger.e('Trigger payout error: $e');
      rethrow;
    }
  }

  /// Get payout history for a user
  Future<List<Payout>> getUserPayoutHistory({
    required String groupId,
    required String userId,
  }) async {
    try {
      _logger.i(
          'Getting payout history for user $userId in group $groupId');

      final payouts =
          await _firestoreService.getUserPayoutSchedule(groupId, userId);

      _logger.i('Found ${payouts.length} payouts');

      return payouts;
    } catch (e) {
      _logger.e('Get user payout history error: $e');
      rethrow;
    }
  }

  /// Get payout statistics for a group
  Future<Map<String, dynamic>> getPayoutStatistics(String groupId) async {
    try {
      _logger.i('Getting payout statistics for group $groupId');

      final payouts = await _firestoreService.getGroupPayouts(groupId);

      int completedCount = 0;
      int pendingCount = 0;
      int scheduledCount = 0;
      int failedCount = 0;
      double totalPayedOut = 0;
      double totalScheduled = 0;

      for (final payout in payouts) {
        if (payout.isCompleted) {
          completedCount++;
          totalPayedOut += payout.amount;
        } else if (payout.isPending) {
          pendingCount++;
          totalScheduled += payout.amount;
        } else if (payout.isScheduled) {
          scheduledCount++;
          totalScheduled += payout.amount;
        } else if (payout.status == PayoutStatus.failed) {
          failedCount++;
        }
      }

      final stats = {
        'totalPayouts': payouts.length,
        'completedCount': completedCount,
        'pendingCount': pendingCount,
        'scheduledCount': scheduledCount,
        'failedCount': failedCount,
        'totalPayedOut': totalPayedOut,
        'totalScheduled': totalScheduled,
        'completionPercentage': payouts.isEmpty
            ? 0
            : (completedCount / payouts.length * 100),
      };

      _logger.i('Payout statistics: $stats');

      return stats;
    } catch (e) {
      _logger.e('Get payout statistics error: $e');
      rethrow;
    }
  }

  /// Cancel payout
  Future<void> cancelPayout({
    required String groupId,
    required String payoutId,
  }) async {
    try {
      _logger.i('Cancelling payout $payoutId for group $groupId');

      final payouts = await _firestoreService.getGroupPayouts(groupId);
      final payout = payouts.firstWhere(
        (p) => p.payoutId == payoutId,
        orElse: () => throw Exception('Payout not found'),
      );

      if (payout.isCompleted) {
        throw Exception('Cannot cancel completed payout');
      }

      final cancelledPayout = payout.copyWith(
        status: PayoutStatus.cancelled,
      );

      await _firestoreService.savePayout(cancelledPayout);

      _logger.i('Payout cancelled');
    } catch (e) {
      _logger.e('Cancel payout error: $e');
      rethrow;
    }
  }
}
