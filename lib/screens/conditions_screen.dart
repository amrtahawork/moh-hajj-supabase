import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

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
    'امراض الشريان التاجي (ذبحة صدرية جلطة بالقلب)',
    'التليف الكبدي',
    'القصور الكلوي',
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
  final TextEditingController _otherConditionController =
      TextEditingController();
  bool _showOtherTextField = false;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    for (var condition in _conditions) {
      _selectedConditions[condition] = false;
    }
    _selectedConditions['otherConditionText'] = '';
    _fetchConditions();
  }

  @override
  void dispose() {
    _otherConditionController.dispose();
    super.dispose();
  }

  Future<void> _fetchConditions() async {
    setState(() {
      _isLoading = true;
    });
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final data =
        await _supabaseService.client
            .from('conditions')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
    if (data != null) {
      setState(() {
        for (var condition in _conditions) {
          _selectedConditions[condition] = data[condition] ?? false;
        }
        _selectedConditions['otherConditionText'] =
            data['otherConditionText'] ?? '';
        _showOtherTextField = data['أمراض أخرى (أذكرها):'] ?? false;
        _otherConditionController.text = data['otherConditionText'] ?? '';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveConditions() async {
    setState(() {
      _isLoading = true;
    });
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    Map<String, dynamic> conditionsData = {'user_id': userId};
    for (var condition in _conditions) {
      if (_selectedConditions[condition] == true) {
        conditionsData[condition] = true;
      } else {
        conditionsData[condition] = false;
      }
    }
    if (_selectedConditions['أمراض أخرى (أذكرها):'] == true &&
        _selectedConditions['otherConditionText'].toString().isNotEmpty) {
      conditionsData['otherConditionText'] =
          _selectedConditions['otherConditionText'];
    } else {
      conditionsData['otherConditionText'] = '';
    }
    conditionsData['updated_at'] = DateTime.now().toIso8601String();
    final result = await _supabaseService.client
        .from('conditions')
        .upsert(conditionsData);
    setState(() {
      _isLoading = false;
    });
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الحالات الصحية في Supabase')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ الحالات الصحية في Supabase')),
      );
    }
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
                                  _selectedConditions['otherConditionText'] =
                                      '';
                                }
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        if (_showOtherTextField &&
                            condition == 'أمراض أخرى (أذكرها):')
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
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
                                _selectedConditions['otherConditionText'] =
                                    value;
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
                onPressed: _isLoading ? null : _saveConditions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
