import 'package:equatable/equatable.dart';

class User extends Equatable {

  const User({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.smegaNumber,
    required this.email,
    required this.registeredDate,
    required this.isKycVerified,
    this.profileImageUrl,
    this.status = UserStatus.active,
  });
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String smegaNumber;
  final String email;
  final DateTime registeredDate;
  final bool isKycVerified;
  final String? profileImageUrl;
  final UserStatus status;

  @override
  List<Object?> get props => [
    userId,
    fullName,
    phoneNumber,
    smegaNumber,
    email,
    registeredDate,
    isKycVerified,
    profileImageUrl,
    status,
  ];

  User copyWith({
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? smegaNumber,
    String? email,
    DateTime? registeredDate,
    bool? isKycVerified,
    String? profileImageUrl,
    UserStatus? status,
  }) => User(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smegaNumber: smegaNumber ?? this.smegaNumber,
      email: email ?? this.email,
      registeredDate: registeredDate ?? this.registeredDate,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      status: status ?? this.status,
    );
}

enum UserStatus { active, inactive, suspended }
