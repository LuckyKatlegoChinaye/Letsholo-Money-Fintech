import '../core/constants/app_constants.dart';
import '../core/utils/api_service.dart';
import '../data/models/transaction_model.dart';
import '../domain/entities/transaction.dart';
import 'package:logger/logger.dart';

class PaymentService {

  PaymentService({required ApiService apiService}) : _apiService = apiService;
  final ApiService _apiService;
  final Logger _logger = Logger();

  /// Initiate a payment/contribution
  Future<Transaction> initiatePayment({
    required String userId,
    required String groupId,
    required String walletId,
    required double amount,
    required String smegarWalletReference,
  }) async {
    try {
      _logger.i('Initiating payment: $amount for group: $groupId');
      
      final data = {
        'user_id': userId,
        'group_id': groupId,
        'wallet_id': walletId,
        'amount': amount,
        'smega_wallet_reference': smegarWalletReference,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.createTransactionEndpoint,
        data: data,
      );

      final transactionModel = TransactionModel.fromJson(response);
      _logger.i('Payment initiated: ${transactionModel.transactionId}');
      
      return transactionModel.toDomain();
    } catch (e) {
      _logger.e('Initiate payment error: $e');
      rethrow;
    }
  }

  /// Process payment through BTC Smegar gateway
  Future<Map<String, dynamic>> processSmegarPayment({
    required String amount,
    required String phoneNumber,
    required String reference,
  }) async {
    try {
      _logger.i('Processing Smegar payment for: $phoneNumber, amount: $amount');
      
      // This will call the BTC Smegar API
      final data = {
        'amount': amount,
        'phone_number': phoneNumber,
        'reference': reference,
        'callback_url': 'https://api.letsholomoney.com/api/v1/payments/callback',
      };

      // Note: This endpoint is on the Smegar server
      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.smegarInitiatePaymentEndpoint,
        data: data,
      );

      _logger.i('Smegar payment processed');
      return response;
    } catch (e) {
      _logger.e('Smegar payment error: $e');
      rethrow;
    }
  }

  /// Check payment status
  Future<TransactionStatus> checkPaymentStatus({
    required String transactionId,
  }) async {
    try {
      _logger.i('Checking payment status: $transactionId');
      
      final endpoint = '${AppConstants.getTransactionsEndpoint}/$transactionId';
      final response = await _apiService.get<Map<String, dynamic>>(endpoint);

      final transactionModel = TransactionModel.fromJson(response);
      _logger.i('Payment status: ${transactionModel.status}');
      
      return transactionModel.toDomain().status;
    } catch (e) {
      _logger.e('Check payment status error: $e');
      rethrow;
    }
  }

  /// Get transaction history for a user
  Future<List<Transaction>> getUserTransactions({
    required String userId,
    int page = 1,
  }) async {
    try {
      _logger.i('Fetching transactions for user: $userId');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.getTransactionsEndpoint,
        queryParameters: {
          'user_id': userId,
          'page': page,
          'limit': AppConstants.pageSize,
        },
      );

      final transactions = response['transactions'] as List;
      final transactionList = transactions
          .map((t) =>
              TransactionModel.fromJson(t as Map<String, dynamic>).toDomain())
          .toList();

      _logger.i('Fetched ${transactionList.length} transactions');
      return transactionList;
    } catch (e) {
      _logger.e('Get user transactions error: $e');
      rethrow;
    }
  }

  /// Get transaction history for a group
  Future<List<Transaction>> getGroupTransactions({
    required String groupId,
    int page = 1,
  }) async {
    try {
      _logger.i('Fetching transactions for group: $groupId');
      
      final endpoint = AppConstants.getGroupTransactionsEndpoint
          .replaceAll('{groupId}', groupId);
      
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {
          'page': page,
          'limit': AppConstants.pageSize,
        },
      );

      final transactions = response['transactions'] as List;
      final transactionList = transactions
          .map((t) =>
              TransactionModel.fromJson(t as Map<String, dynamic>).toDomain())
          .toList();

      _logger.i('Fetched ${transactionList.length} group transactions');
      return transactionList;
    } catch (e) {
      _logger.e('Get group transactions error: $e');
      rethrow;
    }
  }

  /// Apply late payment fee
  Future<Transaction> applyLatePaymentFee({
    required String transactionId,
    required double feeAmount,
  }) async {
    try {
      _logger.i('Applying late payment fee to: $transactionId');
      
      final data = {
        'late_payment_fee': feeAmount,
      };

      final response = await _apiService.patch<Map<String, dynamic>>(
        '${AppConstants.getTransactionsEndpoint}/$transactionId',
        data: data,
      );

      final transactionModel = TransactionModel.fromJson(response);
      return transactionModel.toDomain();
    } catch (e) {
      _logger.e('Apply late payment fee error: $e');
      rethrow;
    }
  }

  /// Refund a transaction (through BTC Smegar)
  Future<bool> refundTransaction({
    required String smegarTransactionReference,
    required double amount,
  }) async {
    try {
      _logger.i('Processing refund for: $smegarTransactionReference');
      
      final data = {
        'transaction_reference': smegarTransactionReference,
        'amount': amount,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.smegarRefundEndpoint,
        data: data,
      );

      _logger.i('Refund processed');
      return response['success'] ?? false;
    } catch (e) {
      _logger.e('Refund error: $e');
      rethrow;
    }
  }

  /// Calculate late payment fee
  double calculateLateFee(double originalAmount) {
    return originalAmount * 0.10; // 10% late fee
  }

  /// Split fee between platform and group
  Map<String, double> splitFeeDistribution(double totalFee) {
    final platformFee = totalFee * AppConstants.platformPenaltyPercentage;
    final groupFee = totalFee * AppConstants.groupPenaltyPercentage;

    return {
      'platform_fee': platformFee,
      'group_fee': groupFee,
    };
  }
}
