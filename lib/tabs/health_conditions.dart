import 'package:flutter/material.dart';
import '../screens/allergies_screen.dart';
import '../screens/medication_screen.dart';
import '../screens/conditions_screen.dart';
import '../screens/other_factors_screen.dart';
import '../screens/comments_screen.dart';

class HealthConditionsTab extends StatefulWidget {
  const HealthConditionsTab({super.key});

  @override
  State<HealthConditionsTab> createState() => _HealthConditionsTabState();
}

class _HealthConditionsTabState extends State<HealthConditionsTab> {
  String? _selectedItem;
  List<String> _savedAllergies = []; // Add state variable for allergies

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مدخلاتي الصحية',
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildListItems(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListItems() {
    final items = [
      _buildListItem("الحساسية", Icons.warning_amber, "allergies"),
      _buildListItem("الأدوية", Icons.local_pharmacy, "medication"),
      _buildListItem("الحالات المرضية", Icons.medical_services, "conditions"),
      _buildListItem("عوامل أخرى", Icons.info, "other_factors"),
      _buildListItem("ملاحظات", Icons.comment, "comments"),
    ];
    return items;
  }

  Widget _buildListItem(String text, IconData icon, String identifier) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF4285F4), size: 24),
        ),
        title: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: const Color(0xFF4285F4),
        ),
        onTap: () => _handleListItemTap(identifier),
        hoverColor: Colors.transparent,
      ),
    );
  }

  void _handleListItemTap(String identifier) async {
    // Make the function async
    setState(() {
      _selectedItem = identifier;
    });
    final screenRoutes = {
      "allergies": const AllergiesScreen(),
      "medication": const MedicationScreen(),
      "conditions": const ConditionsScreen(),
      "other_factors": const OtherFactorsScreen(),
      "comments": const CommentsScreen(),
    };

    if (screenRoutes.containsKey(identifier)) {
      // Use rootNavigator: true to push the screen above the BottomNavigationBar
      final navigator = Navigator.of(context, rootNavigator: true);

      if (identifier == "allergies") {
        // Navigate and wait for result using the root navigator
        final result = await navigator.push<List<String>>(
          MaterialPageRoute(builder: (context) => screenRoutes[identifier]!),
        );
        if (result != null && mounted) {
          // Check if the widget is still mounted
          setState(() {
            _savedAllergies = result;
            // TODO: Pass this data up to the parent (MainScreen)
            print("Received allergies: $_savedAllergies"); // For debugging
          });
        }
      } else {
        // Navigate normally for other screens using the root navigator
        navigator.push(
          MaterialPageRoute(builder: (context) => screenRoutes[identifier]!),
        );
      }
    }
  }
}
