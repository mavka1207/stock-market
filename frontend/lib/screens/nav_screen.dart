import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/nav_provider.dart';
import 'watchlist_screen.dart';
import 'trade_screen.dart';
import 'wallet_screen.dart';
import 'history_screen.dart';

class NavScreen extends StatelessWidget {
  static const String routeName = '/app';
  
  const NavScreen({super.key});

  static const List<String> _titles = [
    'My Watchlist',
    'Trade Stocks',
    'My Wallet',
    'Historical Data',
  ];

  static const List<Widget> _pages = [
    WatchlistScreen(),
    TradeScreen(),
    WalletScreen(),
    HistoryScreen(),
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
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _pages[nav.currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.currentIndex,
        onDestinationSelected: nav.setIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.show_chart),
            label: 'Watchlist',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz),
            label: 'Trade',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'History',
          ),
        ],
      ),
    );
  }
}