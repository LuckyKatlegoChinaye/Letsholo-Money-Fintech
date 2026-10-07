import 'package:equatable/equatable.dart';

class Penalty extends Equatable {

  const Penalty({
    required this.penaltyId,
    required this.groupId,
    required this.userId,
    required this.amount,
    required this.reason,
    required this.createdAt,
    this.isPaid = false,
    this.paidAt,
  });
  final String penaltyId;
  final String groupId;
  final String userId;
  final double amount;
  final String reason;
  final DateTime createdAt;
  final bool isPaid;
  final DateTime? paidAt;

  @override
  List<Object?> get props => [
    penaltyId,
    groupId,
    userId,
    amount,
    reason,
    createdAt,
    isPaid,
    paidAt,
  ];

  Penalty copyWith({
    String? penaltyId,
    String? groupId,
    String? userId,
    double? amount,
    String? reason,
    DateTime? createdAt,
    bool? isPaid,
    DateTime? paidAt,
  }) => Penalty(
      penaltyId: penaltyId ?? this.penaltyId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
    );
}
