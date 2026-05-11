import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/stocks_provider.dart'; 
import 'login_screen.dart';
import 'watchlist_screen.dart';
import 'trade_screen.dart';
import 'wallet_screen.dart';
// import 'history_screen.dart';

class NavScreen extends StatefulWidget { 
  static const String routeName = '/app';
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  late StocksProvider _stocksProvider;

  @override
  void initState() {
    super.initState();
    // start timer once for ALL screens
    _stocksProvider = context.read<StocksProvider>();
    Future.microtask(() {
      if (!mounted) return;
      _stocksProvider.startRealTimeUpdates();
    });
  }

  @override
  void dispose() {
    // stop only when leaving the app (logout)
    _stocksProvider.stopRealTimeUpdates();
    super.dispose();
  }

  static const List<String> _titles = [
    'My Watchlist',
    'Trade Stocks',
    'My Wallet',
    // 'Historical Data',
  ];

  static const List<Widget> _pages = [
    WatchlistScreen(),
    TradeScreen(),
    WalletScreen(),
    // HistoryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[nav.currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              _stocksProvider.stopRealTimeUpdates(); // stop before logout
              context.read<AuthProvider>().logout();
              context.read<WalletProvider>().clear();
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: _pages[nav.currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.currentIndex,
        onDestinationSelected: nav.setIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'Watchlist'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Trade'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          // NavigationDestination(icon: Icon(Icons.bar_chart), label: 'History'),
        ],
      ),
    );
  }
}
