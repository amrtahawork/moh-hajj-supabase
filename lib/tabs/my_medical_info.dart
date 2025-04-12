import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
class MyMedicalInfoTab extends StatefulWidget {
  const MyMedicalInfoTab({super.key});

  @override
  State<MyMedicalInfoTab> createState() => _MyMedicalInfoTabState();
}

class _MyMedicalInfoTabState extends State<MyMedicalInfoTab> {
  List<String> _selectedConditions = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedConditions();
  }

  Future<void> _loadSelectedConditions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medical_conditions.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final List<dynamic> decodedData = jsonDecode(jsonData);
        setState(() {
          _selectedConditions = decodedData.cast<String>();
        });
      } else {
        setState(() {
          _selectedConditions = [];
        });
        // Create the file if it doesn't exist and save an empty list
        final jsonData = jsonEncode([]);
        await file.writeAsString(jsonData);
        setState(() {
          _selectedConditions = [];
          print("Created medical_conditions.json with empty data");
        });
      }
    } catch (e) {
      setState(() {
        _selectedConditions = [];
      });
      print("Error loading conditions: $e");
    }
  }

  String _getConditionText(String condition) {
    // You can customize how each condition is displayed
    return condition;
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Medical History',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _selectedConditions.isEmpty
              ? const Text('No medical history available.')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _selectedConditions.map((condition) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• ${_getConditionText(condition)}'),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}