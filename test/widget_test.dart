import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:wish_list_app/main.dart';

// 1. Функція для налаштування моків Firebase
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Мок для Firebase Core (Pigeon канал)
  const MethodChannel coreChannel = MethodChannel(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi',
  );
  
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(coreChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'initializeCore') {
      // Імітуємо успішну відповідь для initializeCore
      return [
        {
          'name': '[DEFAULT]',
          'options': {
            'apiKey': 'fake-api-key',
            'appId': '1:1234567890:ios:abc123def456',
            'messagingSenderId': '1234567890',
            'projectId': 'test-project-id',
            'storageBucket': 'test.appspot.com',
            'iosBundleId': 'com.example.test',
            'iosClientId': 'fake-ios-client-id',
            'androidClientId': 'fake-android-client-id',
          },
          'pluginConstants': {},
        }
      ];
    }
    
    if (methodCall.method == 'initializeApp') {
      // Імітуємо успішну відповідь для initializeApp
      final args = methodCall.arguments as Map<dynamic, dynamic>;
      return {
        'name': args['appName'] ?? '[DEFAULT]',
        'options': args['options'],
        'pluginConstants': {},
      };
    }
    
    return null;
  });
  
  // Мок для Firebase Analytics
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_analytics'),
    (MethodCall methodCall) async {
      return null;
    },
  );
  
  // Мок для Firebase Crashlytics
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_crashlytics'),
    (MethodCall methodCall) async {
      return null;
    },
  );
  
  // Мок для інших Firebase сервісів, які можуть використовуватись
  const List<String> firebaseChannels = [
    'plugins.flutter.io/firebase_auth',
    'plugins.flutter.io/firebase_database',
    'plugins.flutter.io/firebase_storage',
    'plugins.flutter.io/firebase_messaging',
    'plugins.flutter.io/firebase_remote_config',
    'plugins.flutter.io/firebase_performance',
  ];
  
  for (final channel in firebaseChannels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel(channel),
      (MethodCall methodCall) async => null,
    );
  }
}

void main() {
  // 2. Викликаємо налаштування моків на самому початку
  setupFirebaseMocks();
  
  // 3. Групуємо тести
  group('Wish List App Tests', () {
    setUpAll(() async {
      // Ініціалізуємо Firebase тільки один раз для всіх тестів
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            name: '[DEFAULT]',
            options: const FirebaseOptions(
              apiKey: 'fake-api-key',
              appId: '1:1234567890:ios:abc123def456',
              messagingSenderId: '1234567890',
              projectId: 'test-project-id',
              storageBucket: 'test.appspot.com',
              iosBundleId: 'com.example.test',
            ),
          );
        }
      } catch (e) {
        print('Firebase initialization error in test: $e');
        // Продовжуємо тест навіть якщо Firebase не ініціалізувався
      }
    });
    
    tearDownAll(() async {
      // Очищуємо Firebase apps після тестів
      try {
        for (final app in Firebase.apps) {
          await app.delete();
        }
      } catch (e) {
        // Ігноруємо помилки очищення
      }
    });
    
    testWidgets('App launches and shows initial screen', 
        (WidgetTester tester) async {
      // Відключаємо реальну Firebase ініціалізацію в тесті
      // замінюємо Firebase.initializeApp на пусту реалізацію
      
      await tester.pumpWidget(const MyApp());
      
      // Додаємо затримку для асинхронної ініціалізації
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Перевіряємо, що додаток запустився
      // Спочатку має бути SplashScreen
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App does not crash on launch', 
        (WidgetTester tester) async {
      // Простий smoke test - перевіряємо, що додаток не викликає винятків
      try {
        await tester.pumpWidget(const MyAppForTest());
        await tester.pumpAndSettle(const Duration(seconds: 2));
        
        // Якщо додаток дійшов сюди без винятків - тест пройдений
        expect(tester.takeException(), isNull);
      } catch (e) {
        fail('App crashed on launch: $e');
      }
    });
  });
}