import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local_db/account_store.dart';
import 'data/local_db/session_store.dart';
import 'data/security/crypto_service.dart';
import 'data/security/secure_media_store.dart';
import 'screens/splash_screen.dart';
import 'services/auth_service.dart';
import 'state/session_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final crypto = await CryptoService.init();
  final accountStore = await AccountStore.open(crypto);
  final auth = AuthService(accountStore);
  await auth.seedDemoAccount();

  final session = SessionState(auth, SecureSessionStore());
  await session.restore();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionState>.value(value: session),
        Provider<SecureMediaStore>.value(value: SecureMediaStore(crypto)),
      ],
      child: const EvoqeApp(),
    ),
  );
}

class EvoqeApp extends StatelessWidget {
  const EvoqeApp({super.key});

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
      home: const SplashScreen(),
    );
  }
}