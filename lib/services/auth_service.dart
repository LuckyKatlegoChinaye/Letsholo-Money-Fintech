import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import '../domain/entities/user.dart';
import 'firestore_service.dart';

class AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger();

  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _firebaseAuth.currentUser != null && _currentUser != null;

  /// Create account with email and password
  /// Returns the created User after saving to Firestore
  Future<User> createAccountWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty || fullName.isEmpty) {
      throw Exception('Email, password, and full name are required');
    }

    try {
      _logger.i('Creating account for email: $email');

      // Create Firebase Auth user
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Account creation failed - no user returned from Firebase');
      }

      _logger.i('Firebase Auth user created: ${firebaseUser.uid}');

      // Update display name
      try {
        await firebaseUser.updateDisplayName(fullName);
        _logger.i('Display name updated successfully');
      } catch (e) {
        _logger.w('Warning: Could not update display name: $e');
      }

      // Create user profile with all required fields
      _currentUser = User(
        userId: firebaseUser.uid,
        fullName: fullName,
        phoneNumber: '',
        smegaNumber: '',
        email: email,
        registeredDate: DateTime.now(),
        isKycVerified: false,
        profileImageUrl: null,
        status: UserStatus.active,
      );

      // Save to Firestore with retry logic
      try {
        await _saveUserToFirestore(_currentUser!);
        _logger.i('User profile saved to Firestore successfully');
      } catch (firestoreError) {
        _logger.e('Firestore error: $firestoreError');
        // Don't fail account creation if Firestore save fails - user is already in Auth
        _logger.w('Warning: User created but profile save to Firestore failed');
      }

      return _currentUser!;
    } on auth.FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      String errorMessage = 'Registration failed: ${e.message}';
      
      if (e.code == 'weak-password') {
        errorMessage = 'Password is too weak. Please use at least 8 characters with uppercase, lowercase, and numbers.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use. Please login or use a different email.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'Email/password accounts are not enabled. Please contact support.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      _logger.e('Create account error: $e');
      throw Exception('Account creation failed: ${e.toString()}');
    }
  }

  /// Login with email and password
  /// Returns User after loading profile from Firestore
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password are required');
    }

    try {
      _logger.i('Logging in with email: $email');

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw Exception('Login failed - no user returned from Firebase');
      }

      _logger.i('User logged in: ${firebaseUser.uid}');

      // Load user profile from Firestore
      try {
        final userProfile = await _firestoreService.getUserProfile(firebaseUser.uid);

        if (userProfile != null) {
          _currentUser = userProfile;
          _logger.i('User profile loaded from Firestore');
        } else {
          // Create default user profile if doesn't exist (first login)
          _currentUser = User(
            userId: firebaseUser.uid,
            fullName: firebaseUser.displayName ?? 'User',
            phoneNumber: '',
            smegaNumber: '',
            email: email,
            registeredDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
            isKycVerified: false,
            profileImageUrl: firebaseUser.photoURL,
            status: UserStatus.active,
          );
          
          // Save profile to Firestore
          await _saveUserToFirestore(_currentUser!);
          _logger.i('User profile created in Firestore');
        }
      } catch (firestoreError) {
        _logger.e('Error loading/creating user profile: $firestoreError');
        // Still allow login even if Firestore has issues
        _currentUser = User(
          userId: firebaseUser.uid,
          fullName: firebaseUser.displayName ?? 'User',
          phoneNumber: '',
          smegaNumber: '',
          email: email,
          registeredDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
          isKycVerified: false,
          profileImageUrl: firebaseUser.photoURL,
          status: UserStatus.active,
        );
      }

      return _currentUser!;
    } on auth.FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      String errorMessage = 'Login failed';
      
      if (e.code == 'wrong-password') {
        errorMessage = 'Invalid password. Please try again.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email. Please register first.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email format.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled. Please contact support.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'Invalid email or password.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many login attempts. Please try again later.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      _logger.e('Login error: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Sign in with Google
  /// Returns User - creates profile if first time, or loads existing profile
  Future<User> signInWithGoogle() async {
    try {
      _logger.i('Starting Google Sign-In...');

      // Sign out first to ensure fresh login
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        _logger.w('Could not sign out from Google: $e');
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in was cancelled');
      }

      _logger.i('Google user signed in: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;
      if (googleAuth.accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Google authentication failed - no user returned');
      }

      _logger.i('Firebase user authenticated: ${firebaseUser.uid}');

      // Check if user already exists in Firestore
      try {
        final existingUser = await _firestoreService.getUserProfile(firebaseUser.uid);

        if (existingUser != null) {
          _currentUser = existingUser;
          _logger.i('Existing user profile loaded');
        } else {
          // First-time Google user - create profile
          _currentUser = User(
            userId: firebaseUser.uid,
            fullName: googleUser.displayName ?? googleUser.email.split('@')[0],
            phoneNumber: '',
            smegaNumber: '',
            email: googleUser.email,
            registeredDate: DateTime.now(),
            isKycVerified: false,
            profileImageUrl: googleUser.photoUrl,
            status: UserStatus.active,
          );

          // Save to Firestore
          await _saveUserToFirestore(_currentUser!);
          _logger.i('New user profile created in Firestore');
        }
      } catch (firestoreError) {
        _logger.w('Firestore operation failed: $firestoreError');
        // Create in-memory user if Firestore fails
        _currentUser = User(
          userId: firebaseUser.uid,
          fullName: googleUser.displayName ?? googleUser.email.split('@')[0],
          phoneNumber: '',
          smegaNumber: '',
          email: googleUser.email,
          registeredDate: DateTime.now(),
          isKycVerified: false,
          profileImageUrl: googleUser.photoUrl,
          status: UserStatus.active,
        );
      }

      return _currentUser!;
    } on auth.FirebaseAuthException catch (e) {
      _logger.e('Firebase Auth error: ${e.code} - ${e.message}');
      throw Exception('Google sign-in failed: ${e.message}');
    } catch (e) {
      _logger.e('Google sign-in error: $e');
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _logger.i('Logging out user...');

      await _firebaseAuth.signOut();
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        _logger.w('Could not sign out from Google: $e');
      }

      _currentUser = null;
      _logger.i('Logout successful');
    } catch (e) {
      _logger.e('Logout error: $e');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    if (_firebaseAuth.currentUser != null && _currentUser == null) {
      final firebaseUser = _firebaseAuth.currentUser!;
      _currentUser = User(
        userId: firebaseUser.uid,
        fullName: firebaseUser.displayName ?? 'User',
        phoneNumber: '',
        smegaNumber: '',
        email: firebaseUser.email ?? '',
        registeredDate: firebaseUser.metadata.creationTime ?? DateTime.now(),
        isKycVerified: false,
        profileImageUrl: firebaseUser.photoURL,
        status: UserStatus.active,
      );
    }
    return _currentUser;
  }

  /// Get current Firebase user ID
  String? getCurrentUserId() => _firebaseAuth.currentUser?.uid;

  /// Helper method to save user to Firestore with proper error handling
  Future<void> _saveUserToFirestore(User user) async {
    try {
      _logger.i('Saving user to Firestore: ${user.userId}');

      // Verify user is authenticated
      final currentAuthUser = auth.FirebaseAuth.instance.currentUser;
      if (currentAuthUser == null) {
        throw Exception('User not authenticated. Cannot save to Firestore.');
      }

      // Add delay to ensure auth state is propagated
      await Future.delayed(const Duration(milliseconds: 500));

      // Prepare user data
      final userData = {
        'user_id': user.userId,
        'full_name': user.fullName,
        'phone_number': user.phoneNumber,
        'smega_number': user.smegaNumber,
        'email': user.email,
        'registered_date': user.registeredDate,
        'is_kyc_verified': user.isKycVerified,
        'profile_image_url': user.profileImageUrl,
        'status': user.status.name,
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Save with merge to avoid overwriting other data
      await _firestore
          .collection('users')
          .doc(user.userId)
          .set(userData, SetOptions(merge: true));

      _logger.i('User saved to Firestore successfully');
    } on FirebaseException catch (e) {
      _logger.e('Firestore error: ${e.code} - ${e.message}');
      throw Exception('Failed to save user profile: ${e.message}');
    } catch (e) {
      _logger.e('Error saving user: $e');
      throw Exception('Failed to save user profile: ${e.toString()}');
    }
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      _logger.i('Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.i('Password reset email sent');
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }

  /// Listen to authentication state changes
  /// Returns a stream of authentication state
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
