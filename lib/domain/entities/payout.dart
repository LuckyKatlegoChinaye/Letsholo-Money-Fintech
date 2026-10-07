import 'package:equatable/equatable.dart';

class Payout extends Equatable {

  const Payout({
    required this.payoutId,
    required this.groupId,
    required this.receiverId,
    required this.amount,
    required this.payoutOrder,
    required this.status,
    required this.scheduledDate,
    this.completedDate,
    this.paymentReference,
  });
  final String payoutId;
  final String groupId;
  final String receiverId;
  final double amount;
  final int payoutOrder;
  final PayoutStatus status;
  final DateTime scheduledDate;
  final DateTime? completedDate;
  final String? paymentReference;

  @override
  List<Object?> get props => [
    payoutId,
    groupId,
    receiverId,
    amount,
    payoutOrder,
    status,
    scheduledDate,
    completedDate,
    paymentReference,
  ];

  bool get isCompleted => status == PayoutStatus.completed;

  bool get isPending => status == PayoutStatus.pending;

  bool get isScheduled => status == PayoutStatus.scheduled;

  Payout copyWith({
    String? payoutId,
    String? groupId,
    String? receiverId,
    double? amount,
    int? payoutOrder,
    PayoutStatus? status,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? paymentReference,
  }) => Payout(
      payoutId: payoutId ?? this.payoutId,
      groupId: groupId ?? this.groupId,
      receiverId: receiverId ?? this.receiverId,
      amount: amount ?? this.amount,
      payoutOrder: payoutOrder ?? this.payoutOrder,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      paymentReference: paymentReference ?? this.paymentReference,
    );
}

enum PayoutStatus { scheduled, pending, completed, failed, cancelled }
