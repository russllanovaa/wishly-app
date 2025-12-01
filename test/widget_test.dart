import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core/firebase_core.dart';
// НЕ використовуємо firebase_core_platform_interface.dart
// Використовуємо пряму імітацію MethodChannel.

import 'package:wish_list_app/main.dart';
// Можливо, знадобиться імпорт SplashScreen, якщо він не імпортується автоматично
// import 'screens/misc/splash_screen.dart';


// --- ОСНОВНИЙ БЛОК ТЕСТІВ ---

void main() {
  // 1. ІНІЦІАЛІЗАЦІЯ ЗАГЛУШОК ПЛАТФОРМИ (Mock Handlers)
  // Цей код повинен бути виконаний негайно.
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // A. Заглушка для НОВОГО КАНАЛУ Pigeon (FirebaseCoreHostApi.initializeCore)
  // Ми імітуємо канал, який використовується для викликів HostApi.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'initializeCore') {
        // Імітуємо успішну ініціалізацію 'DEFAULT' додатка
        return [
          {
            'name': 'test',
            'options': {
              'appId': '1:1234567890:ios:4e4d67c5269739a8',
              'apiKey': 'fakeApiKey',
              'projectId': 'test-project',
              'messagingSenderId': '1234567890',
            },
            'pluginConstants': {},
          },
        ];
      }
      if (methodCall.method == 'initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );

  // B. Заглушка для Firebase Analytics (старий MethodChannel, залишаємо для сумісності)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_analytics'),
    (MethodCall methodCall) async {
      return null;
    },
  );

  // C. Заглушка для Firebase Crashlytics (старий MethodChannel, залишаємо для сумісності)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_crashlytics'),
    (MethodCall methodCall) async {
      return null;
    },
  );

  // 2. АСИНХРОННА ІНІЦІАЛІЗАЦІЯ Firebase у тестах
  setUpAll(() async {
    // Якщо Firebase ще не ініціалізовано, виконуємо імітований виклик initializeApp.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          appId: '1:1234567890:ios:4e4d67c5269739a8',
          apiKey: 'fakeApiKey',
          projectId: 'test-project',
          messagingSenderId: '1234567890',
        ),
      ); 
    }
  });


  testWidgets('App launches and renders initial route without crash', (WidgetTester tester) async {
    // 3. Запуск віджета
    await tester.pumpWidget(const MyApp());
    
    // Чекаємо, доки всі асинхронні операції (ініціалізація Firebase, перехід на SplashScreen/AuthGate) завершаться
    await tester.pumpAndSettle(); 

    // ПЕРЕВІРКА (Smoke Test): додаток успішно побудовано, і головний віджет існує.
    expect(find.byType(MyApp), findsOneWidget); 
  });
}