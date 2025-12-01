import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

import 'dart:async';

import 'screens/wishlist/bloc/wishlist_bloc.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/misc/loading_screen.dart';
import 'screens/misc/splash_screen.dart';
import 'screens/wishlist/wishlist_detail_screen.dart';
import 'screens/wishlist/add_edit_item_screen.dart';

import 'repository/wishlist_repository.dart';
import 'repository/wish_item_repository.dart';
import 'repository/storage_repository.dart';

import 'screens/wishlist/add_edit_item/add_edit_item_bloc.dart';
import 'screens/wishlist/bloc/WishItemBloc/wish_item_bloc.dart';

import 'models/wishlist.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logEvent(
    name: 'app_started',
    parameters: {'source': 'manual_test'},
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runZonedGuarded<Future<void>>(() async {
    runApp(const MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => WishlistRepository()),
        RepositoryProvider(create: (context) => WishItemRepository()),
        RepositoryProvider(create: (context) => StorageRepository()),
      ],
      child: BlocProvider(
        create: (context) => WishlistBloc(
          wishlistRepository: context.read<WishlistRepository>(),
        ), 
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Wish List',
          theme: ThemeData(
            primaryColor: const Color(0xFF8A2BE2),
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8A2BE2)),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Poppins',
          ),
          initialRoute: '/splash',
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: analytics),
          ],
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/auth_gate': (context) => const AuthGate(),
            '/loading': (context) => const LoadingScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            
            '/wishlist_detail': (context) => BlocProvider(
                  create: (blocContext) => WishItemBloc(
                    itemRepository: blocContext.read<WishItemRepository>(),
                    wishlistRepository: blocContext.read<WishlistRepository>(),
                  ),
                  child: WishlistDetailScreen(
                    // Тепер, коли 'Wishlist' імпортовано, 'as Wishlist' спрацює
                    wishlist: ModalRoute.of(context)!.settings.arguments as Wishlist,
                  ),
                ),
            
            '/add_edit_item': (context) => BlocProvider(
                  create: (blocContext) => AddEditItemBloc(
                    itemRepository: blocContext.read<WishItemRepository>(),
                    storageRepository: blocContext.read<StorageRepository>(),
                    wishlistRepository: blocContext.read<WishlistRepository>(),
                  ),
                  child: const AddEditItemScreen(),
                ),
          },
        ),
      ),
    );
  }
}