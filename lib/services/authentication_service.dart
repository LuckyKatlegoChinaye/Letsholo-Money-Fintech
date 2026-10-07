import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/api_service.dart';
import '../data/models/user_model.dart';
import '../domain/entities/user.dart';
import 'package:logger/logger.dart';

class AuthenticationService {

  AuthenticationService({
    required ApiService apiService,
    required FlutterSecureStorage secureStorage,
  })  : _apiService = apiService,
        _secureStorage = secureStorage;
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger = Logger();

  User? _currentUser;
  String? _accessToken;

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _currentUser != null;

  /// Register a new user
  Future<User> register({
    required String fullName,
    required String phoneNumber,
    required String smegaNumber,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Registering user: $phoneNumber');
      
      final data = {
        'full_name': fullName,
        'phone_number': phoneNumber,
        'smega_number': smegaNumber,
        'email': email,
        'password': password,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.registerEndpoint,
        data: data,
      );

      final userModel = UserModel.fromJson(response);
      _currentUser = userModel.toDomain();

      _logger.i('User registered successfully: ${_currentUser?.userId}');
      return _currentUser!;
    } catch (e) {
      _logger.e('Registration error: $e');
      rethrow;
    }
  }

  /// Login with phone and password
  Future<User> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _logger.i('Logging in user: $phoneNumber');
      
      final data = {
        'phone_number': phoneNumber,
        'password': password,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.loginEndpoint,
        data: data,
      );

      _accessToken = response['access_token'];
      final userModel = UserModel.fromJson(response['user'] ?? response);
      _currentUser = userModel.toDomain();

      // Save token securely
      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: _accessToken,
      );

      _logger.i('Login successful');
      return _currentUser!;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  /// Login with Smegar account
  Future<User> loginWithSmegar({
    required String smegarNumber,
    required String smegarPassword,
  }) async {
    try {
      _logger.i('Logging in with Smegar: $smegarNumber');
      
      final data = {
        'smega_number': smegarNumber,
        'smega_password': smegarPassword,
      };

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.loginWithSmegarEndpoint,
        data: data,
      );

      _accessToken = response['access_token'];
      final userModel = UserModel.fromJson(response['user'] ?? response);
      _currentUser = userModel.toDomain();

      await _secureStorage.write(
        key: AppConstants.tokenKey,
        value: _accessToken,
      );

      _logger.i('Smegar login successful');
      return _currentUser!;
    } catch (e) {
      _logger.e('Smegar login error: $e');
      rethrow;
    }
  }

  /// Verify KYC status with Smegar
  Future<bool> verifyKyc({required String smegarNumber}) async {
    try {
      _logger.i('Verifying KYC for: $smegarNumber');
      
      final data = {'smega_number': smegarNumber};

      final response = await _apiService.post<Map<String, dynamic>>(
        AppConstants.verifyKycEndpoint,
        data: data,
      );

      final isVerified = response['kyc_verified'] ?? false;
      
      if (isVerified && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(isKycVerified: true);
      }

      _logger.i('KYC verification result: $isVerified');
      return isVerified;
    } catch (e) {
      _logger.e('KYC verification error: $e');
      rethrow;
    }
  }

  /// Get current user details
  Future<User> getCurrentUser() async {
    try {
      _logger.i('Fetching current user details');
      
      final response = await _apiService.get<Map<String, dynamic>>(
        AppConstants.getUserEndpoint,
      );

      final userModel = UserModel.fromJson(response);
      _currentUser = userModel.toDomain();

      return _currentUser!;
    } catch (e) {
      _logger.e('Get current user error: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _logger.i('Logging out user');
      
      _currentUser = null;
      _accessToken = null;

      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.refreshTokenKey);

      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
      rethrow;
    }
  }

  /// Restore session from secure storage
  Future<bool> restoreSession() async {
    try {
      _logger.i('Restoring session');
      
      final token = await _secureStorage.read(key: AppConstants.tokenKey);
      
      if (token != null) {
        _accessToken = token;
        await getCurrentUser();
        _logger.i('Session restored');
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('Restore session error: $e');
      return false;
    }
  }
}
