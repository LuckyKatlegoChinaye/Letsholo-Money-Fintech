import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'presentation/screens/auth/login_screen.dart';

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("Firebase connected successfully");

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const LetshaloMoneyApp());
}

class LetshaloMoneyApp extends StatefulWidget {
  const LetshaloMoneyApp({super.key});

  @override
  State<LetshaloMoneyApp> createState() => _LetshaloMoneyAppState();
}

class _LetshaloMoneyAppState extends State<LetshaloMoneyApp> {
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _notificationService = NotificationService();
    await _notificationService.initialize(
      onMessage: _handleNotification,
      onMessageOpened: _handleNotificationOpened,
    );
  }

  void _handleNotification(RemoteMessage message) {
    final data = NotificationData.fromRemoteMessage(message);
    print('Notification: ${data.title} - ${data.body}');
    // Show local notification or update UI
  }

  void _handleNotificationOpened(RemoteMessage message) {
    final data = NotificationData.fromRemoteMessage(message);
    print('Notification opened: ${data.type}');
    // Navigate to appropriate screen based on notification type
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Letsholo Money',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF27a745),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF27a745),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27a745),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.all(16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF27a745),
              width: 2,
            ),
          ),
          hintStyle: GoogleFonts.inter(color: Colors.grey),
          labelStyle: GoogleFonts.inter(color: Colors.grey[700]),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
}
