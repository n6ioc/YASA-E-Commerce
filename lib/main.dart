import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/localization.dart';

import 'controllers/cart_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/auth_controller.dart';

import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'models/app_preferences.dart';
import 'firebase_options.dart';
import 'controllers/profile_controller.dart';
import 'controllers/orders_controller.dart';

const bool USE_FIREBASE = true; // now enabled after FlutterFire configure

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure flutter_localization is initialized before use.
  await FlutterLocalization.instance.ensureInitialized();
  // Initialize Firebase for current platform (Web/Android/etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final storage = await StorageService.create();
  final initialPrefs = await storage.loadPreferences();
  final firebase = USE_FIREBASE ? await FirebaseService.createEnabled() : FirebaseService.noop();
  final authService = USE_FIREBASE ? await AuthServiceFirebase.create() : await AuthServiceDummy.create();
  runApp(AppRoot(storage: storage, firebase: firebase, auth: authService, initialPrefs: initialPrefs));
}

class AppRoot extends StatelessWidget {
  final StorageService storage;
  final FirebaseService firebase;
  final AuthService auth;
  final AppPreferences initialPrefs;
  const AppRoot({super.key, required this.storage, required this.firebase, required this.auth, required this.initialPrefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<StorageService>.value(value: storage),
        Provider<FirebaseService>.value(value: firebase),
        Provider<AuthService>.value(value: auth),
        ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController(storage, initialPrefs)),
        ChangeNotifierProvider<ProductController>(create: (c) => ProductController(api: c.read<ApiService>(), firebase: c.read<FirebaseService>())..init()),
        ChangeNotifierProvider<CartController>(create: (c) => CartController(storage: c.read<StorageService>(), firebase: c.read<FirebaseService>())..restore()),
        ChangeNotifierProvider<OrdersController>(create: (c) => OrdersController(storage: c.read<StorageService>())),
        ChangeNotifierProvider<ProfileController>(create: (c) => ProfileController(storage: c.read<StorageService>())),
        ChangeNotifierProvider<AuthController>(create: (c) => AuthController(c.read<AuthService>())),
      ],
      child: const _ThemedApp(),
    );
  }
}

class _ThemedApp extends StatefulWidget {
  const _ThemedApp();

  @override
  State<_ThemedApp> createState() => _ThemedAppState();
}

class _ThemedAppState extends State<_ThemedApp> {
  final FlutterLocalization _localization = FlutterLocalization.instance;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _localization.init(mapLocales: kAppLocales, initLanguageCode: 'en');
    _localization.onTranslatedLanguage = (locale) => setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    // Ensure per-user profile is loaded whenever auth state changes
    final auth = context.watch<AuthController>();
    if (auth.isSignedIn && auth.user!.uid != _lastUid) {
      _lastUid = auth.user!.uid;
      final pc = context.read<ProfileController>();
      // Defer to end of frame to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pc.ensureForUser(uid: auth.user!.uid, email: auth.user!.email);
      });
    }
    final theme = buildAppTheme(seedIndex: settings.prefs.seedColorIndex, darkMode: settings.prefs.themeMode == ThemeMode.dark);
    return MaterialApp.router(
      title: 'YASA Commerce',
      theme: theme.light, darkTheme: theme.dark, themeMode: settings.prefs.themeMode,
      routerConfig: createRouter(),
      supportedLocales: _localization.supportedLocales,
      localizationsDelegates: _localization.localizationsDelegates,
    );
  }
}