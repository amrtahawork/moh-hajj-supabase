import 'package:flutter/material.dart';
import '../screens/allergies_screen.dart';
import '../screens/medication_screen.dart';
import '../screens/blood_type_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildListItems(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildListItems() {
    final items = [
      _buildListItem("Allergies", Icons.warning_amber, "allergies"),
      _buildListItem("Medication", Icons.local_pharmacy, "medication"),
      _buildListItem("Blood Type", Icons.bloodtype, "blood_type"),
      _buildListItem("Conditions", Icons.medical_services, "conditions"),
      _buildListItem("Other factors", Icons.info, "other_factors"),
      _buildListItem("Comments", Icons.comment, "comments"),
    ];
    return items;
  }

  Widget _buildListItem(String text, IconData icon, String identifier) {
    final isSelected = _selectedItem == identifier;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD9E2FF) : Colors.white,

        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFD9E2FF),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Icon(
          icon,
          color: Theme.of(context).iconTheme.color,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: _buildTrailingIcon(isSelected),
        onTap: () => _handleListItemTap(identifier),
        hoverColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTrailingIcon(bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : const Color(0xFFD9E2FF),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isSelected ? Theme.of(context).primaryColor : Colors.black,
      ),
    );
  }

  void _handleListItemTap(String identifier) {
    setState(() {
      _selectedItem = identifier;
    });
    final screenRoutes = {
      "allergies": const AllergiesScreen(),
      "medication": const MedicationScreen(),
      "blood_type": const BloodTypeScreen(),
      "conditions": const ConditionsScreen(),
      "other_factors": const OtherFactorsScreen(),
      "comments": const CommentsScreen(),
    };

    if (screenRoutes.containsKey(identifier)) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screenRoutes[identifier]!));
    }
  }
}