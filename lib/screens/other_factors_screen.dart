import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory, getTemporaryDirectory;

class OtherFactorsScreen extends StatefulWidget {
  const OtherFactorsScreen({super.key});

  @override
  State<OtherFactorsScreen> createState() => _OtherFactorsScreenState();
}

class _OtherFactorsScreenState extends State<OtherFactorsScreen> {
  final Map<String, bool> _medicalProcedures = {
    'تم حجزك في مستشفى': false,
    'تم حجزك في رعاية مركزة': false,
    'أجريت لك عملية جراحية': false,
    'أجريت لك قسطرة قلبية أو مخية': false,
    'أجريت لك جلسات غسيل كلوي': false,
    'أجريت لك جلسات علاج كيماوي/إشعاعي': false,
    'أجري لك منظار جهاز هضمي': false,
    'أجري لك منظار آخر (أذكر نوعه)': false,
    'تمت لك إجراءات أخرى (أذكرها)': false,
  };

  final TextEditingController _detailsController = TextEditingController();
  bool _showDetailsField = false;

  // Added missing map used in _buildCheckboxes
  final Map<String, String> _procedureCategories = {
    // Assign appropriate categories based on the procedures in _medicalProcedures
    'تم حجزك في مستشفى': 'الإقامة بالمستشفى',
    'تم حجزك في رعاية مركزة': 'الإقامة بالمستشفى',
    'أجريت لك عملية جراحية': 'إجراءات جراحية',
    'أجريت لك قسطرة قلبية أو مخية': 'إجراءات تدخلية',
    'أجريت لك جلسات غسيل كلوي': 'علاجات مزمنة',
    'أجريت لك جلسات علاج كيماوي/إشعاعي': 'علاجات مزمنة',
    'أجري لك منظار جهاز هضمي': 'إجراءات تشخيصية',
    'أجري لك منظار آخر (أذكر نوعه)': 'إجراءات تشخيصية',
    'تمت لك إجراءات أخرى (أذكرها)': 'إجراءات أخرى',
    // Note: The original failed search block contained keys not present in _medicalProcedures
    // like 'التليف الكبدي', 'نزيف بالمخ / جلطة بالمخ', 'أنزيف من الفم'.
    // These have been omitted here as they don't match the checkboxes being built.
    // Adjust categories as needed for clinical accuracy.
  };

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<Directory?> _getStorageDirectory() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('خطأ في الوصول إلى مجلد التخزين: $e');
      try {
        return await getTemporaryDirectory();
      } catch (e) {
        print('خطأ في الوصول إلى المجلد المؤقت: $e');
        return null;
      }
    }
  }

  Future<void> _loadSavedData() async {
    try {
      final directory = await _getStorageDirectory();
      if (directory == null) {
        print('لم يتم العثور على مجلد للتخزين');
        return;
      }

      final file = File('${directory.path}/medical_procedures.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final Map<String, dynamic> decodedData = jsonDecode(jsonData);
        
        setState(() {
          for (var key in _medicalProcedures.keys) {
            if (decodedData.containsKey(key)) {
              _medicalProcedures[key] = decodedData[key] == true;
            }
          }
          
          if (decodedData.containsKey('details')) {
            _detailsController.text = decodedData['details'];
          }
          
          _updateDetailsFieldVisibility();
        });
      }
    } catch (e) {
      print('Error loading medical procedures: $e');
    }
  }

  Future<void> _saveData() async {
    try {
      final directory = await _getStorageDirectory();
      if (directory == null) {
        throw Exception('لم يتم العثور على مجلد للتخزين');
      }

      final Map<String, dynamic> dataToSave = {};
      for (var entry in _medicalProcedures.entries) {
        dataToSave[entry.key] = entry.value;
      }
      dataToSave['details'] = _detailsController.text;

      final file = File('${directory.path}/medical_procedures.json');
      await file.writeAsString(jsonEncode(dataToSave));

      // Update medical conditions
      final conditionsFile = File('${directory.path}/medical_conditions.json');
      Map<String, dynamic> medicalConditions = {};
      
      if (await conditionsFile.exists()) {
        final jsonData = await conditionsFile.readAsString();
        medicalConditions = jsonDecode(jsonData);
      }

      for (var entry in _medicalProcedures.entries) {
        if (entry.value) {
          medicalConditions[entry.key] = true;
        }
      }

      if (_detailsController.text.isNotEmpty && _showDetailsField) {
        medicalConditions['otherConditionText'] = _detailsController.text;
      }

      await conditionsFile.writeAsString(jsonEncode(medicalConditions));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ المعلومات بنجاح')),
      );
    } catch (e) {
      print('Error saving medical data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء حفظ المعلومات: ${e.toString()}')),
      );
    }
  }

  void _updateDetailsFieldVisibility() {
    setState(() {
      // Only show details field if the specific 'other' checkboxes are checked
      _showDetailsField = _medicalProcedures['أجري لك منظار آخر (أذكر نوعه)'] == true ||
                          _medicalProcedures['تمت لك إجراءات أخرى (أذكرها)'] == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'عوامل أخرى',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'هل حدث لك أيا مما يلي:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._buildCheckboxes(),
                      if (_showDetailsField) ...[  
                        const SizedBox(height: 16),
                        const Text('أدخل التفاصيل:'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _detailsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'أدخل التفاصيل هنا...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCheckboxes() {
    return _medicalProcedures.keys.map((procedure) {
      return CheckboxListTile(
        title: Text(procedure),
        value: _medicalProcedures[procedure],
        onChanged: (bool? value) {
          setState(() {
            _medicalProcedures[procedure] = value ?? false;
            _updateDetailsFieldVisibility();
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        dense: true,
      );
    }).toList();
  }
}
