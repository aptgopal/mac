import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../explore/explore_screen.dart';
import '../trips/trips_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExploreScreen(),
    TripsScreen(),
    ProfileScreen(showBottomNavigationBar: false),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_rounded,
                color: _currentIndex == 0
                    ? theme.colorScheme.primary
                    : Colors.grey),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_rounded,
                color: _currentIndex == 1
                    ? theme.colorScheme.primary
                    : Colors.grey),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.flight_takeoff_rounded,
                color: _currentIndex == 2
                    ? theme.colorScheme.primary
                    : Colors.grey),
            label: 'Trips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded,
                color: _currentIndex == 3
                    ? theme.colorScheme.primary
                    : Colors.grey),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
