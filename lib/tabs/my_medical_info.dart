import 'package:flutter/material.dart';
import 'dart:convert';
class MyMedicalInfoTab extends StatefulWidget {
  const MyMedicalInfoTab({super.key});

  @override
  State<MyMedicalInfoTab> createState() => _MyMedicalInfoTabState();
}

class _MyMedicalInfoTabState extends State<MyMedicalInfoTab> {
  Map<String, bool> _selectedConditions = {};

  @override
  void initState() {
    super.initState();
    _loadSelectedConditions();
  }
  Future<String> get _localPath async {
    // Assume you want to store it in the application documents directory
    // For simplicity, we're placing it in the root for now.  Adjust as needed.
    return '.';
  }

  Future<dynamic> get _localFile async {
    final path = await _localPath;
    return '$path/medical_conditions.json';
  }

  Future<void> _loadSelectedConditions() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      setState(() {
        _selectedConditions = Map<String, bool>.from(jsonDecode(contents));
      });
    } catch (e) {
      // If encountering an error, return default values or handle as needed
      setState(() {
        _selectedConditions = {};
      });
      print("Error loading conditions: $e");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Medical Conditions',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          _selectedConditions.isEmpty
              ? const Text('No medical conditions selected.')
              :  Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: _selectedConditions.entries
                .where((entry) => entry.value)
                .map((entry) => Chip(
              label: Text(entry.key),
            ))
                .toList(),
          )

        ],
      ),
    );
  }
}