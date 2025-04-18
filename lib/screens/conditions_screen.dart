import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ConditionsScreen extends StatefulWidget {
  const ConditionsScreen({super.key});

  @override
  State<ConditionsScreen> createState() => _ConditionsScreenState();
}

class _ConditionsScreenState extends State<ConditionsScreen> {
  final List<String> _conditions = [
    'الضغط',
    'السكر',
    'ضعف عضلة القلب',
    'مراض الشريان التاجي (ذبحة صدرية بلطة بالقلب)',
    'التليف الكبدي',
    'القصور ور الكلوي',
    'أورام',
    'نزيف بالمخ / جلطة بالمخ',
    'شلل نصفي / شلل رباعي',
    'أمراض عصبية أو نفسية',
    'نزيف من الفم',
    'نزيف من فتحة الشرج',
    'فرحة بالمعدة أو الإثنا عشر',
    'حساسية الصدر (الربو)',
    'درن (سل)',
    'تليف بالرئة',
    'أمراض مناعية',
    'أمراض دم مزمنة',
    'أمراض أخرى (أذكرها):',
  ];

  final Map<String, dynamic> _selectedConditions = {};
  final TextEditingController _otherConditionController = TextEditingController();
  bool _showOtherTextField = false;

  @override
  void initState() {
    super.initState();
    for (var condition in _conditions) {
      _selectedConditions[condition] = false;
    }
    _selectedConditions['otherConditionText'] = '';
  }
  
  @override
  void dispose() {
    _otherConditionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحالات الصحية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل عانيت سابقاً أو حالياً من مرض :',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _conditions.length,
                  itemBuilder: (context, index) {
                    final condition = _conditions[index];
                    return Column(
                      children: [
                        CheckboxListTile(
                          title: Text(condition),
                          value: _selectedConditions[condition] as bool,
                          onChanged: (bool? value) {
                            setState(() {
                              _selectedConditions[condition] = value!;
                              if (condition == 'أمراض أخرى (أذكرها):') {
                                _showOtherTextField = value;
                                if (!value) {
                                  _otherConditionController.clear();
                                  _selectedConditions['otherConditionText'] = '';
                                }
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        if (_showOtherTextField && condition == 'أمراض أخرى (أذكرها):')
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: TextField(
                              controller: _otherConditionController,
                              decoration: InputDecoration(
                                hintText: 'اكتب الأمراض الأخرى هنا',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              textDirection: TextDirection.rtl,
                              onChanged: (value) {
                                _selectedConditions['otherConditionText'] = value;
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  Map<String, dynamic> conditionsData = {};
                  
                  // Add selected conditions
                  for (var condition in _conditions) {
                    if (_selectedConditions[condition] == true) {
                      conditionsData[condition] = true;
                    }
                  }
                  
                  // Add other condition text if applicable
                  if (_selectedConditions['أمراض أخرى (أذكرها):'] == true && 
                      _selectedConditions['otherConditionText'].toString().isNotEmpty) {
                    conditionsData['otherConditionText'] = _selectedConditions['otherConditionText'];
                  }
                  
                  final directory = await getApplicationDocumentsDirectory();
                  final file = File('${directory.path}/medical_conditions.json');
                  final data = jsonEncode(conditionsData);

                  if (!await file.exists()) {
                    await file.create();
                  }

                  await file.writeAsString(data);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ الحالات الصحية.')),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('حفظ'),
              ), // Added closing parenthesis here
          ],
        ),
      ),
    ));
  }
}
