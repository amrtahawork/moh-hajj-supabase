import 'package:flutter/material.dart';
import 'package:hajj_health_pass/tabs/health_conditions.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class MyMedicalInfoTab extends StatefulWidget {
  const MyMedicalInfoTab({super.key});

  @override
  State<MyMedicalInfoTab> createState() => _MyMedicalInfoTabState();
}

class _MyMedicalInfoTabState extends State<MyMedicalInfoTab> {
  Map<String, dynamic> _medicalConditions = {};
  List<String> _selectedConditionKeys = [];
  String _otherConditionText = '';
  bool _isLoading = true;

  // Added state for blood type selection
  String? _selectedBloodType;
  String? _selectedRhFactor;
  final List<bool> _bloodTypeSelection = List.generate(4, (_) => false);
  final List<bool> _rhFactorSelection = List.generate(2, (_) => false);
  final List<String> _bloodTypes = ['A', 'B', 'AB', 'O'];
  final List<String> _rhFactors = ['+', '-'];

  final Map<String, Color> _categoryColors = {
    'الضغط': Colors.red.shade100,
    'السكر': Colors.blue.shade100,
    'القلب': Colors.purple.shade100,
    'الكبد': Colors.green.shade100,
    'الكلى': Colors.orange.shade100,
    'العصبية': Colors.indigo.shade100,
    'أخرى': Colors.grey.shade100,
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedConditions();
    _loadBloodType(); // Load saved blood type
  }

  Future<void> _loadSelectedConditions() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/medical_conditions.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final Map<String, dynamic> decodedData = jsonDecode(jsonData);
        setState(() {
          _medicalConditions = decodedData;
          _selectedConditionKeys = _medicalConditions.keys
              .where((key) => _medicalConditions[key] == true)
              .toList();
          _otherConditionText = _medicalConditions['otherConditionText'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _medicalConditions = {};
          _selectedConditionKeys = [];
          _isLoading = false;
        });
        final jsonData = jsonEncode({});
        await file.writeAsString(jsonData);
      }
    } catch (e) {
      print('Error loading medical conditions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Added method to load saved blood type (example using shared_preferences, needs dependency)
  // For simplicity, we'll just initialize it here. Add shared_preferences if persistence is needed.
  Future<void> _loadBloodType() async {
    // Example: Load from storage if implemented
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // setState(() {
    //   _selectedBloodType = prefs.getString('bloodType');
    //   _selectedRhFactor = prefs.getString('rhFactor');
    //   // Update selection arrays based on loaded values if needed
    // });
  }

  // Added method to save blood type (example using shared_preferences)
  Future<void> _saveBloodType() async {
    // Example: Save to storage if implemented
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setString('bloodType', _selectedBloodType ?? '');
    // await prefs.setString('rhFactor', _selectedRhFactor ?? '');
    print('Saving Blood Type: $_selectedBloodType$_selectedRhFactor'); // Placeholder
  }

  // Copied and adapted from BloodTypeScreen
  void _showBloodTypeDialog() {
    List<bool> dialogBloodTypeSelection = List.from(_bloodTypeSelection);
    List<bool> dialogRhFactorSelection = List.from(_rhFactorSelection);
    String? dialogSelectedBloodType = _selectedBloodType;
    String? dialogSelectedRhFactor = _selectedRhFactor;

    // Pre-select based on current state
    if (_selectedBloodType != null) {
      int bloodIndex = _bloodTypes.indexOf(_selectedBloodType!);
      if (bloodIndex != -1) {
        for (int i = 0; i < dialogBloodTypeSelection.length; i++) {
          dialogBloodTypeSelection[i] = i == bloodIndex;
        }
      }
    }
    if (_selectedRhFactor != null) {
      int rhIndex = _rhFactors.indexOf(_selectedRhFactor!);
      if (rhIndex != -1) {
        for (int i = 0; i < dialogRhFactorSelection.length; i++) {
          dialogRhFactorSelection[i] = i == rhIndex;
        }
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('اختر فصيلة دمك'), // Arabic title
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('اختر فصيلة الدم'), // Arabic text
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: dialogBloodTypeSelection,
                    onPressed: (int index) {
                      setDialogState(() {
                        for (int i = 0; i < dialogBloodTypeSelection.length; i++) {
                          dialogBloodTypeSelection[i] = i == index;
                        }
                        dialogSelectedBloodType = _bloodTypes[index];
                      });
                    },
                    children: _bloodTypes.map((type) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(type),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('اختر عامل Rh'), // Arabic text
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: dialogRhFactorSelection,
                    onPressed: (int index) {
                      setDialogState(() {
                        for (int i = 0; i < dialogRhFactorSelection.length; i++) {
                          dialogRhFactorSelection[i] = i == index;
                        }
                        dialogSelectedRhFactor = _rhFactors[index];
                      });
                    },
                    children: _rhFactors.map((factor) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(factor),
                    )).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'), // Arabic text
                ),
                ElevatedButton(
                  onPressed: () {
                    if (dialogSelectedBloodType != null && dialogSelectedRhFactor != null) {
                      setState(() {
                        _selectedBloodType = dialogSelectedBloodType;
                        _selectedRhFactor = dialogSelectedRhFactor;
                        _bloodTypeSelection.setAll(0, dialogBloodTypeSelection);
                        _rhFactorSelection.setAll(0, dialogRhFactorSelection);
                      });
                      _saveBloodType(); // Save the selection
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('تم حفظ فصيلة الدم: $_selectedBloodType$_selectedRhFactor')), // Arabic text
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('الرجاء اختيار فصيلة الدم وعامل Rh')), // Arabic text
                      );
                    }
                  },
                  child: const Text('حفظ'), // Arabic text
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getConditionColor(String condition) {
    for (var entry in _categoryColors.entries) {
      if (condition.contains(entry.key)) {
        return entry.value;
      }
    }
    return _categoryColors['أخرى'] ?? Colors.grey.shade100;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedConditionKeys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_information_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد معلومات طبية مسجلة',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthConditionsTab(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة معلومات طبية'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.medical_information,
                              color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'المعلومات الطبية',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      // Add Blood Type ListTile
                      Card(
                        color: Colors.pink.shade100, // Example color for blood type
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.bloodtype, color: Colors.red),
                          title: const Text(
                            'فصيلة الدم', // Arabic text
                            style: TextStyle(fontSize: 16),
                          ),
                          subtitle: Text(_selectedBloodType != null && _selectedRhFactor != null
                              ? '$_selectedBloodType$_selectedRhFactor'
                              : 'غير محدد'), // Show selected or 'Not set'
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _showBloodTypeDialog, // Call the dialog on tap
                        ),
                      ),
                      // Existing conditions list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedConditionKeys.length,
                        itemBuilder: (context, index) {
                          final condition = _selectedConditionKeys[index];
                          if (condition == 'otherConditionText') return Container();
                          return Card(
                            color: _getConditionColor(condition),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                condition,
                                style: const TextStyle(fontSize: 16),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () {
                                // Handle condition tap
                              },
                            ),
                          );
                        },
                      ),
                      if (_otherConditionText.isNotEmpty) ...[                        
                        Card(
                          color: _categoryColors['أخرى'],
                          margin: const EdgeInsets.only(top: 8),
                          child: ListTile(
                            title: const Text('حالات أخرى'),
                            subtitle: Text(_otherConditionText),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HealthConditionsTab(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('تعديل المعلومات الطبية'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(double.infinity, 48), // Make button wider
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}