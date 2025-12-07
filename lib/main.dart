import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/categories_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize notifications on all platforms
  if (kDebugMode) {
    print('🔔 Initializing notifications...');
  }
  try {
    await NotificationService().initialize();
    if (kDebugMode) {
      print('✅ Notifications initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ Notification initialization failed: $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рецепти Апликација',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const CategoriesScreen(),
    );
  }
}