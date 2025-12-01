import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core/firebase_core.dart';
// НЕ використовуємо firebase_core_platform_interface.dart
// Використовуємо пряму імітацію MethodChannel.

import 'package:wish_list_app/main.dart';


// --- ОСНОВНИЙ БЛОК ТЕСТІВ ---

void main() {
  // 1. ІНІЦІАЛІЗАЦІЯ ЗАГЛУШОК ПЛАТФОРМИ (Mock Handlers)
  // Цей код повинен бути виконаний негайно.
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // A. Заглушка для Firebase Core (основний канал)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_core'),
    (MethodCall methodCall) async {
      if (methodCall.method == 'Firebase#initializeCore') {
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
      if (methodCall.method == 'Firebase#initializeApp') {
        return {
          'name': methodCall.arguments['appName'],
          'options': methodCall.arguments['options'],
          'pluginConstants': {},
        };
      }
      return null;
    },
  );

  // B. Заглушка для Firebase Analytics
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_analytics'),
    (MethodCall methodCall) async {
      // Повертаємо успіх для будь-яких викликів Analytics (logEvent, setUserId, etc.)
      return null;
    },
  );

  // C. Заглушка для Firebase Crashlytics (використовується у вашому main.dart: runZonedGuarded)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/firebase_crashlytics'),
    (MethodCall methodCall) async {
      // Повертаємо успіх для ініціалізації та реєстрації помилок
      return null;
    },
  );

  // 2. АСИНХРОННА ІНІЦІАЛІЗАЦІЯ Firebase у тестах
  setUpAll(() async {
    // Якщо Firebase ще не ініціалізовано, виконуємо імітований виклик initializeApp.
    // Цей виклик тепер перехоплюється Mock Handler'ом у пункті 1.A.
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


  testWidgets('Initial app screen loads without crash', (WidgetTester tester) async {
    // 3. Запуск віджета
    await tester.pumpWidget(const MyApp());
    
    // Чекаємо, доки всі асинхронні операції (якщо такі є в SplashScreen/AuthGate) завершаться
    await tester.pumpAndSettle(); 

    // Перевірка (Smoke Test): додаток успішно побудовано.
    expect(find.byType(MyApp), findsOneWidget); 
    
    // Якщо ви хочете перевірити, чи відображається SplashScreen, розкоментуйте:
    // import 'screens/misc/splash_screen.dart'; // потрібно додати цей імпорт, якщо він відсутній
    // expect(find.byType(SplashScreen), findsOneWidget); 
  });
}