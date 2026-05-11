import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'db/local_db.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/stocks_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/history_provider.dart';
import 'providers/nav_provider.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/nav_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalDB.database;
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
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Stock Market App',
        debugShowCheckedModeBanner: false,
        // STYLING THEME
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0D1117),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF58A6FF),
            surface: const Color(0xFF161B22),
            onSurface: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF161B22),
            foregroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF161B22),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: Color(0xFF30363D)),
            ),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: const Color(0xFF161B22),
            indicatorColor: const Color(0xFF58A6FF).withValues(alpha:0.2),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Color(0xFF58A6FF));
              }
              return const IconThemeData(color: Colors.grey);
            }),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Color(0xFF58A6FF), fontSize: 12);
              }
              return const TextStyle(color: Colors.grey, fontSize: 12);
            }),
          ),
          dividerColor: const Color(0xFF30363D),
          useMaterial3: true,
        ),

        // ROUTES
        initialRoute: WelcomeScreen.routeName,
        routes: {
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          LoginScreen.routeName: (context) => const LoginScreen(),
          NavScreen.routeName: (context) => const NavScreen(),
        },
      ),
    );
  }
}