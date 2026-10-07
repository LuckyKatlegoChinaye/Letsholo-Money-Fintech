import 'package:equatable/equatable.dart';

class Wallet extends Equatable {

  const Wallet({
    required this.walletId,
    required this.groupId,
    required this.balance,
    required this.smegarWalletReference,
    required this.createdDate,
    required this.lastUpdated,
    this.isActive = true,
  });
  final String walletId;
  final String groupId;
  final double balance;
  final String smegarWalletReference;
  final DateTime createdDate;
  final DateTime lastUpdated;
  final bool isActive;

  @override
  List<Object?> get props => [
    walletId,
    groupId,
    balance,
    smegarWalletReference,
    createdDate,
    lastUpdated,
    isActive,
  ];

  Wallet copyWith({
    String? walletId,
    String? groupId,
    double? balance,
    String? smegarWalletReference,
    DateTime? createdDate,
    DateTime? lastUpdated,
    bool? isActive,
  }) => Wallet(
      walletId: walletId ?? this.walletId,
      groupId: groupId ?? this.groupId,
      balance: balance ?? this.balance,
      smegarWalletReference:
          smegarWalletReference ?? this.smegarWalletReference,
      createdDate: createdDate ?? this.createdDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isActive: isActive ?? this.isActive,
    );
}
