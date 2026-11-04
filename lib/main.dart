import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'data/local_db/profile_store.dart';
import 'data/security/crypto_service.dart';
import 'data/security/secure_auth_storage.dart';
import 'data/security/secure_media_store.dart';
import 'screens/password_recovery.dart';
import 'screens/splash_screen.dart';
import 'services/app_navigation.dart';
import 'services/auth_service.dart';
import 'state/session_state.dart';

class _AppInitData {
  final SessionState session;
  final SecureMediaStore mediaStore;

  _AppInitData({required this.session, required this.mediaStore});
}

bool _supabaseInitialized = false;

Future<_AppInitData> _initApp() async {
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError('SUPABASE_URL and SUPABASE_ANON_KEY must be configured.');
  }
  if (!_supabaseInitialized) {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureAuthStorage(),
        pkceAsyncStorage: SecureAuthStorage(),
        detectSessionInUriPredicate: _isSupabaseAuthCallback,
      ),
    );
    _supabaseInitialized = true;
  }

  final crypto = await CryptoService.init();
  final profileStore = await ProfileStore.open(crypto);
  final auth = AuthService(Supabase.instance.client, profileStore);

  final session = SessionState(auth);
  await session.restore();

  return _AppInitData(session: session, mediaStore: SecureMediaStore(crypto));
}

bool _isSupabaseAuthCallback(Uri uri) =>
    uri.scheme == 'com.example.evoqe' && uri.host == 'auth-callback';

Widget _buildApp(_AppInitData initData) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SessionState>.value(value: initData.session),
      Provider<SecureMediaStore>.value(value: initData.mediaStore),
    ],
    child: const EvoqeApp(),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final initData = await _initApp();
    runApp(_buildApp(initData));
  } catch (_) {
    runApp(const StartupErrorApp());
  }
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVOQE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E3129),
          surface: const Color(0xFFF5F3EC),
        ),
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const _StartupErrorScreen(),
    );
  }
}

class _StartupErrorScreen extends StatefulWidget {
  const _StartupErrorScreen();

  @override
  State<_StartupErrorScreen> createState() => _StartupErrorScreenState();
}

class _StartupErrorScreenState extends State<_StartupErrorScreen> {
  bool _isLoading = false;

  Future<void> _retryInit() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final initData = await _initApp();
      runApp(_buildApp(initData));
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "EVOQE couldn't start.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF201D19),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Something went wrong while loading your data.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF8C8278)),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 200,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _retryInit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3E3129),
                      foregroundColor: const Color(0xFFF5F3EC),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF5F3EC),
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Text(
                            'Try again',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EvoqeApp extends StatelessWidget {
  const EvoqeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVOQE',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigatorKey,
      routes: {'/password-recovery': (_) => const PasswordRecoveryScreen()},
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F3EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3E3129),
          surface: const Color(0xFFF5F3EC),
        ),
        fontFamily: 'serif',
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
