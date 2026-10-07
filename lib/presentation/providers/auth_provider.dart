import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../services/auth_service.dart';

// ============================================
// AUTH SERVICE PROVIDER
// ============================================
final authServiceProvider = Provider((ref) => AuthService());

// ============================================
// CURRENT USER PROVIDER
// ============================================
final currentUserProvider = Provider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.currentUser ?? authService.getCurrentUser();
});

// ============================================
// AUTHENTICATION STATE PROVIDER
// ============================================
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.isAuthenticated;
});

// ============================================
// AUTH STATE CHANGES STREAM
// ============================================
final authStateChangesProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// ============================================
// EMAIL/PASSWORD SIGN-UP NOTIFIER
// ============================================
class SignUpState {
  SignUpState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  SignUpState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) => SignUpState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isSuccess: isSuccess ?? this.isSuccess,
  );
}

class SignUpNotifier extends StateNotifier<SignUpState> {
  SignUpNotifier(this.authService) : super(SignUpState());
  
  final AuthService authService;

  Future<void> createAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await authService.createAccountWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void resetState() {
    state = SignUpState();
  }
}

final signUpProvider = StateNotifierProvider<SignUpNotifier, SignUpState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignUpNotifier(authService);
});

// ============================================
// EMAIL/PASSWORD LOGIN NOTIFIER
// ============================================
class LoginState {
  LoginState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) => LoginState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isSuccess: isSuccess ?? this.isSuccess,
  );
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier(this.authService) : super(LoginState());
  
  final AuthService authService;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await authService.loginWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  void resetState() {
    state = LoginState();
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginNotifier(authService);
});

// ============================================
// GOOGLE SIGN-IN NOTIFIER
// ============================================
class GoogleSignInState {
  GoogleSignInState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });
  
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  GoogleSignInState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) => GoogleSignInState(
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
    isSuccess: isSuccess ?? this.isSuccess,
  );
}

class GoogleSignInNotifier extends StateNotifier<GoogleSignInState> {
  GoogleSignInNotifier(this.authService) : super(GoogleSignInState());
  
  final AuthService authService;

  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await authService.signInWithGoogle();
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await authService.logout();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final googleSignInProvider = StateNotifierProvider<GoogleSignInNotifier, GoogleSignInState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return GoogleSignInNotifier(authService);
});

