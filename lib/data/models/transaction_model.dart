import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel {

  TransactionModel({
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  factory TransactionModel.fromDomain(Transaction domain) => TransactionModel(
      transactionId: domain.transactionId,
      userId: domain.userId,
      groupId: domain.groupId,
      amount: domain.amount,
      type: domain.type.name,
      status: domain.status.name,
      timestamp: domain.timestamp,
      reference: domain.reference,
      latePaymentFee: domain.latePaymentFee,
      platformFeeDeducted: domain.platformFeeDeducted,
      description: domain.description,
    );
  @JsonKey(name: 'transaction_id')
  final String transactionId;
  
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'group_id')
  final String groupId;
  
  final double amount;
  
  final String type;
  
  final String status;
  
  final DateTime timestamp;
  
  final String? reference;
  
  @JsonKey(name: 'late_payment_fee')
  final double? latePaymentFee;
  
  @JsonKey(name: 'platform_fee_deducted')
  final double? platformFeeDeducted;
  
  final String? description;

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Transaction toDomain() => Transaction(
      transactionId: transactionId,
      userId: userId,
      groupId: groupId,
      amount: amount,
      type: _stringToTransactionType(type),
      status: _stringToTransactionStatus(status),
      timestamp: timestamp,
      reference: reference,
      latePaymentFee: latePaymentFee,
      platformFeeDeducted: platformFeeDeducted,
      description: description,
    );
}

TransactionType _stringToTransactionType(String type) => TransactionType.values.firstWhere(
    (e) => e.name == type,
    orElse: () => TransactionType.deposit,
  );

TransactionStatus _stringToTransactionStatus(String status) => TransactionStatus.values.firstWhere(
    (e) => e.name == status,
    orElse: () => TransactionStatus.pending,
  );
