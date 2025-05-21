// TODO Implement this library.import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mine_detection_app_2/blocs/auth/auth_bloc.dart';
import 'package:mine_detection_app_2/screens/devices_screen.dart';
import 'package:mine_detection_app_2/screens/map_screen.dart';
import 'package:mine_detection_app_2/screens/scans_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MapScreen(),
    const ScansScreen(),
    const DevicesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Система виявлення мін'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 600,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Карта'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Сканування'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.devices),
                label: Text('Пристрої'),
              ),
            ],
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вихід'),
        content: const Text('Ви дійсно бажаєте вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Скасувати'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
  }
}