import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 🔥 Firebase options
import 'firebase_options.dart';

// CORE
import 'core/theme.dart';
import 'core/router.dart';

// SERVICES
import 'services/user_service.dart';
import 'services/presence_service.dart';
import 'services/push_service.dart';
import 'services/offline_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ================= OFFLINE STORAGE =================
  await Hive.initFlutter();
  await Hive.openBox('offline_sales');

  // ================= FIREBASE =================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ================= SUPABASE =================
  await Supabase.initialize(
    url: 'https://xldieslnvykfpdbxpsyk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsZGllc2xudnlrZnBkYnhwc3lrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM5NzM4MTgsImV4cCI6MjA4OTU0OTgxOH0.Boh4gcCRxEr4hh4iIJfFLkIlngzyJf8fSFJfVXh2NTk',
    authOptions: const FlutterAuthClientOptions(
      autoRefreshToken: true,
    ),
  );

  runApp(const MyApp());
}

// ================= APP =================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MG Jewelry',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      onGenerateRoute: AppRouter.generateRoute,
      home: const AuthGate(),
    );
  }
}

// ================= AUTH GATE =================
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate>
    with WidgetsBindingObserver {
  final supabase = Supabase.instance.client;

  final userService = UserService();
  final presence = PresenceService();
  final push = PushService();
  final offline = OfflineService();

  StreamSubscription<AuthState>? _authSub;

  bool _syncing = false;
  bool _initialized = false;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // 🔔 Push notifications (skip for web)
      if (!kIsWeb) {
        await push.init();
      }

      // 🔄 Offline sync
      await _safeSync();

      // 👂 Auth listener
      _listenAuth();

      // 🔐 Check login
      await _checkAuth();
    } catch (e) {
      debugPrint("❌ Init Error: $e");
      _goLogin();
    }
  }

  // ================= SAFE SYNC =================
  Future<void> _safeSync() async {
    if (_syncing) return;

    _syncing = true;
    try {
      await offline.sync();
    } catch (e) {
      debugPrint("❌ Sync Error: $e");
    } finally {
      _syncing = false;
    }
  }

  // ================= AUTH LISTENER =================
  void _listenAuth() {
    _authSub?.cancel();

    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      switch (event) {
        case AuthChangeEvent.signedIn:
          presence.setOnline();
          _safeSync();
          _checkAuth();
          break;

        case AuthChangeEvent.signedOut:
          presence.setOffline();
          _goLogin();
          break;

        default:
          break;
      }
    });
  }

  // ================= LIFECYCLE =================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      presence.setOnline();
      _safeSync();
    } else {
      presence.setOffline();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSub?.cancel();
    presence.setOffline();
    super.dispose();
  }

  // ================= AUTH CHECK =================
  Future<void> _checkAuth() async {
    final session = supabase.auth.currentSession;

    if (session == null) {
      _goLogin();
      return;
    }

    try {
      final profile = await userService.getProfile();

      if (!mounted) return;

      if (profile == null) {
        _goLogin();
        return;
      }

      final user = {
        'id': profile['id'],
        'name': profile['name'] ?? '',
        'email': profile['email'] ?? '',
        'role': profile['role'] ?? 'employee',
      };

      _navigate(user);
    } catch (e) {
      debugPrint("❌ Auth Error: $e");
      _goLogin();
    }
  }

  // ================= NAVIGATION =================
  void _navigate(Map<String, dynamic> user) {
    final role = user['role'];

    if (!mounted) return;

    final route = switch (role) {
      'owner' => '/owner',
      'admin' => '/admin',
      _ => '/employee',
    };

    Navigator.pushReplacementNamed(
      context,
      route,
      arguments: user,
    );
  }

  void _goLogin() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/login');
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}