import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

typedef NotificationHandler = void Function(RemoteMessage);

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final Logger _logger = Logger();

  NotificationHandler? _onMessageHandler;
  NotificationHandler? _onMessageOpenedHandler;

  Future<void> initialize({
    required NotificationHandler onMessage,
    required NotificationHandler onMessageOpened,
  }) async {
    try {
      _logger.i('Initializing Firebase Cloud Messaging');

      _onMessageHandler = onMessage;
      _onMessageOpenedHandler = onMessageOpened;

      // Request user permission for iOS
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i('Notification permission granted: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      _logger.i('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Foreground message received: ${message.notification?.title}');
        _onMessageHandler?.call(message);
      });

      // Handle background messages when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Message opened app: ${message.notification?.title}');
        _onMessageOpenedHandler?.call(message);
      });

      // Handle token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token refreshed: $newToken');
        // Save new token to backend/database
      });

      _logger.i('FCM initialization complete');
    } catch (e) {
      _logger.e('FCM initialization error: $e');
      rethrow;
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      _logger.i('Retrieved FCM token');
      return token;
    } catch (e) {
      _logger.e('Get FCM token error: $e');
      return null;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      _logger.i('Subscribing to topic: $topic');
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic successfully');
    } catch (e) {
      _logger.e('Subscribe to topic error: $e');
      rethrow;
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      _logger.i('Unsubscribing from topic: $topic');
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic successfully');
    } catch (e) {
      _logger.e('Unsubscribe from topic error: $e');
      rethrow;
    }
  }

  /// Subscribe to group notifications
  Future<void> subscribeToGroupNotifications(String groupId) async {
    try {
      final topic = 'group_$groupId';
      await subscribeToTopic(topic);
      _logger.i('Subscribed to group notifications: $groupId');
    } catch (e) {
      _logger.e('Subscribe to group notifications error: $e');
      rethrow;
    }
  }

  /// Unsubscribe from group notifications
  Future<void> unsubscribeFromGroupNotifications(String groupId) async {
    try {
      final topic = 'group_$groupId';
      await unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from group notifications: $groupId');
    } catch (e) {
      _logger.e('Unsubscribe from group notifications error: $e');
      rethrow;
    }
  }
}

class NotificationData {

  NotificationData({
    this.title,
    this.body,
    this.groupId,
    this.userId,
    this.type,
    required this.data,
  });

  factory NotificationData.fromRemoteMessage(RemoteMessage message) => NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      groupId: message.data['group_id'],
      userId: message.data['user_id'],
      type: message.data['type'],
      data: message.data,
    );
  final String? title;
  final String? body;
  final String? groupId;
  final String? userId;
  final String? type;
  final Map<String, dynamic> data;
}
