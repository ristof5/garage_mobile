import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/green_accent_bar.dart';
import 'dashboard/dashboard_screen.dart';
import '../screens/vehicles/vehicle_screen.dart';
import '../screens/services/services_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    DashboardScreen(),
    VehiclesScreen(), 
    ServicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GARAGE'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: GreenAccentBar(),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'VEHICLES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_outlined),
            activeIcon: Icon(Icons.build),
            label: 'SERVICES',
          ),
        ],
      ),
    );
  }
}
