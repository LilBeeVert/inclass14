import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String permissionStatus = 'Unknown';
  String token = 'Not loaded yet';
  String lastHandler = 'None yet';
  String titleText = 'Waiting for notification...';
  String bodyText = 'Send a test FCM message to update this UI.';
  String actionText = 'No action received';
  String screenText = 'home';
  String timestampText = '-';
  Color cardColor = Colors.deepPurple;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  Future<void> _setupFCM() async {
    final settings = await FCMService.instance.requestPermission();

    setState(() {
      permissionStatus = settings.authorizationStatus.name;
    });

    final fcmToken = await FCMService.instance.getToken();
    setState(() {
      token = fcmToken ?? 'No token available';
    });

    _foregroundSub = FCMService.instance.foregroundMessages().listen((message) {
      _applyMessageToUI(message, 'onMessage (Foreground)');
    });

    _openedAppSub = FCMService.instance.openedAppMessages().listen((message) {
      _applyMessageToUI(message, 'onMessageOpenedApp (Background Tap)');
    });

    final initialMessage = await FCMService.instance.getInitialMessage();
    if (initialMessage != null) {
      _applyMessageToUI(initialMessage, 'getInitialMessage (Cold Start)');
    }
  }

  void _applyMessageToUI(RemoteMessage message, String handlerName) {
    final notification = message.notification;
    final data = message.data;

    final incomingTitle =
        notification?.title ?? data['title'] ?? 'No title provided';
    final incomingBody =
        notification?.body ?? data['body'] ?? 'No body provided';

    final action = data['action'] ?? 'no_action';
    final screen = data['screen'] ?? 'home';
    final timestamp = data['timestamp'] ?? DateTime.now().toIso8601String();

    Color newColor = Colors.deepPurple;
    if (action == 'promo') {
      newColor = Colors.orange;
    } else if (action == 'success') {
      newColor = Colors.green;
    } else if (action == 'warning') {
      newColor = Colors.redAccent;
    } else if (action == 'info') {
      newColor = Colors.blue;
    }

    if (!mounted) return;

    setState(() {
      lastHandler = handlerName;
      titleText = incomingTitle;
      bodyText = incomingBody;
      actionText = action;
      screenText = screen;
      timestampText = timestamp.toString();
      cardColor = newColor;
    });

    debugPrint('Handler fired: $handlerName');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Notification title: ${notification?.title}');
    debugPrint('Notification body: ${notification?.body}');
    debugPrint('Data payload: ${message.data}');
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _openedAppSub?.cancel();
    super.dispose();
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 135,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 14 - FCM'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Firebase Cloud Messaging Dashboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _infoTile('Permission', permissionStatus),
                    _infoTile('Last Handler', lastHandler),
                    _infoTile('Screen', screenText),
                    _infoTile('Action', actionText),
                    _infoTile('Timestamp', timestampText),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: cardColor.withValues(alpha: 0.15),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      titleText,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: cardColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      bodyText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'FCM Device Token',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      token,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final newToken = await FCMService.instance.getToken();
                if (!mounted) return;
                setState(() {
                  token = newToken ?? 'No token available';
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Token'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use Firebase Console or an API request to send test notifications.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
