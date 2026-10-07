// ============================================
// CUSTOM EXCEPTIONS
// ============================================

/// Base exception for all authentication errors
abstract class AuthException implements Exception {

  AuthException(this.message, {this.code});
  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Sign-in failed (wrong password, user not found, etc.)
class SignInFailedException extends AuthException {
  SignInFailedException(String message, {String? code})
      : super(message, code: code);
}

/// User account not found
class UserNotFoundException extends AuthException {
  UserNotFoundException(String message) : super(message);
}

/// OTP verification failed
class OtpVerificationFailedException extends AuthException {

  OtpVerificationFailedException(
    String message, {
    this.remainingAttempts = 0,
    this.cooldown,
  }) : super(message);
  final int remainingAttempts;
  final Duration? cooldown;
}

/// OTP rate limit exceeded
class OtpRateLimitExceededException extends AuthException {

  OtpRateLimitExceededException(
    String message, {
    this.cooldown,
  }) : super(message);
  final Duration? cooldown;
}

/// Network error
class NetworkException extends AuthException {
  NetworkException(String message) : super(message, code: 'network-error');
}

/// Firebase configuration error
class FirebaseConfigException extends AuthException {
  FirebaseConfigException(String message)
      : super(message, code: 'firebase-config-error');
}

/// Type conversion error
class TypeCastException extends AuthException {
  TypeCastException(String message)
      : super(message, code: 'type-cast-error');
}

/// Generic auth error
class AuthErrorException extends AuthException {
  AuthErrorException(String message, {String? code})
      : super(message, code: code);
}

// ============================================
// ERROR HANDLER
// ============================================

class AuthErrorHandler {
  /// Parse Firebase Auth errors and convert to custom exceptions
  static AuthException handleFirebaseAuthError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    final errorMessage = error.toString();

    // OTP/Phone errors
    if (errorString.contains('invalid-verification-code')) {
      return OtpVerificationFailedException('Invalid OTP code. Please try again.');
    }

    if (errorString.contains('invalid-phone-number')) {
      return AuthErrorException('Invalid phone number format. Use +XXXXXXXXXXX');
    }

    if (errorString.contains('too-many-requests')) {
      return OtpRateLimitExceededException(
        'Too many requests. Please wait before trying again.',
      );
    }

    // Account errors
    if (errorString.contains('user-not-found')) {
      return UserNotFoundException('User account not found. Please register.');
    }

    if (errorString.contains('wrong-password')) {
      return SignInFailedException('Wrong password. Please try again.');
    }

    if (errorString.contains('user-disabled')) {
      return SignInFailedException('This account has been disabled.');
    }

    if (errorString.contains('email-already-in-use')) {
      return AuthErrorException('This email is already registered.');
    }

    if (errorString.contains('weak-password')) {
      return AuthErrorException('Password is too weak. Use 8+ characters.');
    }

    // Network errors
    if (errorString.contains('network') || 
        errorString.contains('timeout') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return NetworkException('Network error. Check your connection.');
    }

    // Firebase config errors
    if (errorString.contains('firebase') || 
        errorString.contains('configuration') ||
        errorString.contains('pigeonuserdetails') ||
        errorString.contains('list<object>')) {
      return FirebaseConfigException(
        'Firebase configuration error. Phone Authentication may not be enabled.',
      );
    }

    // Type casting errors
    if (errorString.contains('type') || 
        errorString.contains('subtype') ||
        errorString.contains('cast')) {
      return TypeCastException('Data format error. Please try again.');
    }

    // Default
    return AuthErrorException(errorMessage);
  }

  /// Get user-friendly error message
  static String getUserMessage(AuthException exception) {
    if (exception is SignInFailedException) {
      return exception.message;
    } else if (exception is UserNotFoundException) {
      return 'Account not found. Please register first.';
    } else if (exception is OtpVerificationFailedException) {
      return 'Invalid OTP code. ${exception.remainingAttempts > 0 ? '${exception.remainingAttempts} attempts remaining.' : ''}';
    } else if (exception is OtpRateLimitExceededException) {
      return 'Too many requests. Please wait before trying again.';
    } else if (exception is NetworkException) {
      return 'No internet connection. Check your network.';
    } else if (exception is FirebaseConfigException) {
      return 'Service unavailable. Please try again later.';
    } else if (exception is TypeCastException) {
      return 'Data error. Please try again.';
    } else {
      return exception.message;
    }
  }

  /// Log error with context
  static void logError(dynamic error, {String? context}) {
    print('❌ Error${context != null ? ' in $context' : ''}: $error');
  }
}

// ============================================
// FIRESTORE ERROR HANDLER
// ============================================

class FirestoreErrorHandler {
  static String handleFirestoreError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission')) {
      return 'Permission denied. You don\'t have access to this data.';
    }

    if (errorString.contains('not-found')) {
      return 'Data not found.';
    }

    if (errorString.contains('already-exists')) {
      return 'This document already exists.';
    }

    if (errorString.contains('invalid-argument')) {
      return 'Invalid data. Please check and try again.';
    }

    if (errorString.contains('deadline-exceeded')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('unavailable')) {
      return 'Service unavailable. Please try again later.';
    }

    if (errorString.contains('network')) {
      return 'Network error. Check your connection.';
    }

    return 'An error occurred. Please try again.';
  }
}

// ============================================
// RESULT WRAPPER
// ============================================

typedef Result<T> = ({T? data, AuthException? error});

Result<T> successResult<T>(T data) => (data: data, error: null);

Result<T> failureResult<T>(AuthException error) => (data: null, error: error);
