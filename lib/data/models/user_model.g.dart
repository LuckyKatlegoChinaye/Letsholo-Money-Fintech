// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      smegarNumber: json['smega_number'] as String,
      email: json['email'] as String,
      registeredDate: DateTime.parse(json['registered_date'] as String),
      isKycVerified: json['is_kyc_verified'] as bool,
      profileImageUrl: json['profile_image_url'] as String?,
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'user_id': instance.userId,
      'full_name': instance.fullName,
      'phone_number': instance.phoneNumber,
      'smega_number': instance.smegarNumber,
      'email': instance.email,
      'registered_date': instance.registeredDate.toIso8601String(),
      'is_kyc_verified': instance.isKycVerified,
      'profile_image_url': instance.profileImageUrl,
      'status': instance.status,
    };
