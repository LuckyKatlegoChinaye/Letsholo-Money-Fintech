import 'package:equatable/equatable.dart';

class Contribution extends Equatable {

  const Contribution({
    required this.contributionId,
    required this.groupId,
    required this.userId,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.reference,
    this.penalty,
  });
  final String contributionId;
  final String groupId;
  final String userId;
  final double amount;
  final ContributionStatus status;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String? reference;
  final double? penalty;

  @override
  List<Object?> get props => [
    contributionId,
    groupId,
    userId,
    amount,
    status,
    dueDate,
    paidAt,
    reference,
    penalty,
  ];

  bool get isOverdue =>
      status != ContributionStatus.paid &&
      DateTime.now().isAfter(dueDate);

  bool get isPaid => status == ContributionStatus.paid;

  bool get isPending => status == ContributionStatus.pending;

  Contribution copyWith({
    String? contributionId,
    String? groupId,
    String? userId,
    double? amount,
    ContributionStatus? status,
    DateTime? dueDate,
    DateTime? paidAt,
    String? reference,
    double? penalty,
  }) => Contribution(
      contributionId: contributionId ?? this.contributionId,
      groupId: groupId ?? this.groupId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      reference: reference ?? this.reference,
      penalty: penalty ?? this.penalty,
    );
}

enum ContributionStatus { pending, paid, overdue, partial, failed }
