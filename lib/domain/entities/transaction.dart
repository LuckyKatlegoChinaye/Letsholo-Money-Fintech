import 'package:equatable/equatable.dart';

class Transaction extends Equatable {

  const Transaction({
    required this.transactionId,
    required this.userId,
    required this.groupId,
    required this.amount,
    required this.type,
    required this.status,
    required this.timestamp,
    this.reference,
    this.latePaymentFee,
    this.platformFeeDeducted,
    this.description,
  });
  final String transactionId;
  final String userId;
  final String groupId;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime timestamp;
  final String? reference;
  final double? latePaymentFee;
  final double? platformFeeDeducted;
  final String? description;

  @override
  List<Object?> get props => [
    transactionId,
    userId,
    groupId,
    amount,
    type,
    status,
    timestamp,
    reference,
    latePaymentFee,
    platformFeeDeducted,
    description,
  ];

  Transaction copyWith({
    String? transactionId,
    String? userId,
    String? groupId,
    double? amount,
    TransactionType? type,
    TransactionStatus? status,
    DateTime? timestamp,
    String? reference,
    double? latePaymentFee,
    double? platformFeeDeducted,
    String? description,
  }) => Transaction(
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      reference: reference ?? this.reference,
      latePaymentFee: latePaymentFee ?? this.latePaymentFee,
      platformFeeDeducted: platformFeeDeducted ?? this.platformFeeDeducted,
      description: description ?? this.description,
    );

  double get totalAmount {
    double total = amount;
    if (latePaymentFee != null) total += latePaymentFee!;
    return total;
  }
}

enum TransactionType { deposit, withdrawal, fee, refund, penalty, contribution }
enum TransactionStatus { pending, completed, failed, cancelled }
