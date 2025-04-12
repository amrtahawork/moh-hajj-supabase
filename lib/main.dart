import 'package:flutter/material.dart';

import 'tabs/health_conditions.dart';
import 'tabs/important_numbers_addresses.dart';
import 'tabs/my_medical_info.dart';
import 'tabs/my_profile.dart';
import 'tabs/news.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Health App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 2,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const MyProfileTab(),
    const MyMedicalInfoTab(),
    const ImportantNumbersAddressesTab(),
    const HealthConditionsTab(),
    const NewsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _tabs[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            label: 'My Profile',
          ),
          BottomNavigationBarItem(
            icon:  Icon(Icons.medical_information_outlined),
            activeIcon: Icon(Icons.medical_information, color: Theme.of(context).colorScheme.primary),
            label: 'My Medical Info',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.phone_outlined),
            activeIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.primary),
            label: 'Important Numbers & Addresses',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_hospital_outlined),
            activeIcon: Icon(Icons.local_hospital, color: Theme.of(context).colorScheme.primary),
            label: 'Health Conditions',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper, color: Theme.of(context).colorScheme.primary),
            label: 'News',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: const Color.fromARGB(255, 13, 6, 46),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        showUnselectedLabels: true,
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
