import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {

  UserModel({
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.smegarNumber,
    required this.email,
    required this.registeredDate,
    required this.isKycVerified,
    this.profileImageUrl,
    this.status = 'active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle null/empty values gracefully
      final cleanJson = {
        'user_id': json['user_id'] ?? json['userId'] ?? '',
        'full_name': json['full_name'] ?? json['fullName'] ?? 'User',
        'phone_number': json['phone_number'] ?? json['phoneNumber'] ?? '',
        'smega_number': json['smega_number'] ?? json['smegarNumber'] ?? '',
        'email': json['email'] ?? '',
        'registered_date': json['registered_date'] ?? json['registeredDate'] ?? DateTime.now(),
        'is_kyc_verified': json['is_kyc_verified'] ?? json['isKycVerified'] ?? false,
        'profile_image_url': json['profile_image_url'] ?? json['profileImageUrl'],
        'status': json['status'] ?? 'active',
      };
      return _$UserModelFromJson(cleanJson);
    } catch (e) {
      throw Exception('Failed to parse UserModel from JSON: $e');
    }
  }

  factory UserModel.fromDomain(User domain) => UserModel(
      userId: domain.userId,
      fullName: domain.fullName,
      phoneNumber: domain.phoneNumber,
      smegarNumber: domain.smegaNumber,
      email: domain.email,
      registeredDate: domain.registeredDate,
      isKycVerified: domain.isKycVerified,
      profileImageUrl: domain.profileImageUrl,
      status: domain.status.name,
    );
    
  @JsonKey(name: 'user_id')
  final String userId;
  
  @JsonKey(name: 'full_name')
  final String fullName;
  
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  
  @JsonKey(name: 'smega_number')
  final String smegarNumber;
  
  final String email;
  
  @JsonKey(name: 'registered_date')
  final DateTime registeredDate;
  
  @JsonKey(name: 'is_kyc_verified')
  final bool isKycVerified;
  
  @JsonKey(name: 'profile_image_url')
  final String? profileImageUrl;
  
  @JsonKey(name: 'status')
  final String status;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toDomain() {
    try {
      return User(
        userId: userId.isEmpty ? 'unknown' : userId,
        fullName: fullName.isEmpty ? 'User' : fullName,
        phoneNumber: phoneNumber,
        smegaNumber: smegarNumber,
        email: email.isEmpty ? 'unknown@unknown.com' : email,
        registeredDate: registeredDate,
        isKycVerified: isKycVerified,
        profileImageUrl: profileImageUrl,
        status: _stringToUserStatus(status),
      );
    } catch (e) {
      throw Exception('Failed to convert UserModel to User domain: $e');
    }
  }
}

UserStatus _stringToUserStatus(String status) {
  try {
    return UserStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => UserStatus.active,
    );
  } catch (e) {
    return UserStatus.active;
  }
}
