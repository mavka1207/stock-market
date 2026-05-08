import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/local_db.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/stocks_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/history_provider.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
// import 'screens/watchlist_screen.dart'; // uncomment later when you create it

Future<void> main() async {
  // Make sure Flutter is ready before async work
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local database (SQLite / Hive)
  await LocalDB.database;

  // Start the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StocksProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Stock Market App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        initialRoute: WelcomeScreen.routeName,
        routes: {
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          // WatchlistScreen.routeName: (context) => const WatchlistScreen(),
        },
      ),
    );
  }
}