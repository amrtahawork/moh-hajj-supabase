import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'tabs/home.dart';
import 'tabs/my_medical_info.dart';
import 'tabs/health_conditions.dart';
import 'tabs/important_numbers_addresses.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Supabase.initialize(
    url: 'https://lgoondtlxtobdibmplhg.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxnb29uZHRseHRvYmRpYm1wbGhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY4MTMxMDksImV4cCI6MjA2MjM4OTEwOX0.2AXoLLQglITuVYTA1OQHCwA4mlvhRhGp4gboXQ5f-_g',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Pass',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
        Locale('ar', ''), // Arabic, no country code
      ],
      locale: const Locale('ar', ''),
      home: const LoginScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      Home(onTabChange: _onItemTapped),
      const MyMedicalInfoTab(),
      const HealthConditionsTab(),
      const ImportantNumbersAddressesTab(),
    ];
  }

  void _logout() {
    // Navigate back to login screen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40), // Compact app bar height
        child: AppBar(
          title: const Text(
            'Health Pass',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 20),
              onPressed: () {
                // Notification functionality can be implemented here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('الإشعارات غير متوفرة حاليًا')),
                );
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              onPressed: _logout,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      body: SafeArea(child: _tabs[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information_outlined),
            activeIcon: Icon(
              Icons.medical_information,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'حالتي الصحية',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.phone_outlined),
            activeIcon: Icon(
              Icons.phone,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'مدخلاتي الصحية',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_hospital_outlined),
            activeIcon: Icon(
              Icons.local_hospital,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: 'ارقام مهمة ',
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
