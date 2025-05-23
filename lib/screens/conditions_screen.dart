import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser

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

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for conditions fetch: $nationalId');
    if (nationalId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
        );
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await _supabaseService.client
              .from('conditions')
              .select()
              .eq('national_id', nationalId)
              .maybeSingle();

      if (data != null) {
        setState(() {
          // Map each column to the UI state
          _selectedConditions['الضغط'] = data['hypertension'] ?? false;
          _selectedConditions['السكر'] = data['diabetes'] ?? false;
          _selectedConditions['ضعف عضلة القلب'] =
              data['heart_failure'] ?? false;
          _selectedConditions['امراض الشريان التاجي (ذبحة صدرية جلطة بالقلب)'] =
              data['coronary_artery_disease'] ?? false;
          _selectedConditions['التليف الكبدي'] =
              data['liver_fibrosis'] ?? false;
          _selectedConditions['القصور الكلوي'] = data['renal_failure'] ?? false;
          _selectedConditions['أورام'] = data['tumors'] ?? false;
          _selectedConditions['نزيف بالمخ / جلطة بالمخ'] =
              data['brain_bleed'] ?? false;
          _selectedConditions['شلل نصفي / شلل رباعي'] =
              data['hemiplegia'] ?? false;
          _selectedConditions['أمراض عصبية أو نفسية'] =
              data['neuro_psych'] ?? false;
          _selectedConditions['نزيف من الفم'] = data['mouth_bleed'] ?? false;
          _selectedConditions['نزيف من فتحة الشرج'] =
              data['rectal_bleed'] ?? false;
          _selectedConditions['فرحة بالمعدة أو الإثنا عشر'] =
              data['stomach_ulcer'] ?? false;
          _selectedConditions['حساسية الصدر (الربو)'] = data['asthma'] ?? false;
          _selectedConditions['درن (سل)'] = data['tuberculosis'] ?? false;
          _selectedConditions['تليف بالرئة'] = data['lung_fibrosis'] ?? false;
          _selectedConditions['أمراض مناعية'] = data['autoimmune'] ?? false;
          _selectedConditions['أمراض دم مزمنة'] =
              data['chronic_blood_disease'] ?? false;
          _selectedConditions['أمراض أخرى (أذكرها):'] =
              (data['other_conditions'] != null &&
                      data['other_conditions'] != '')
                  ? true
                  : false;
          _selectedConditions['otherConditionText'] =
              data['other_conditions'] ?? '';
          _otherConditionController.text =
              _selectedConditions['otherConditionText'];
          _showOtherTextField =
              _selectedConditions['أمراض أخرى (أذكرها):'] ?? false;
        });
      }
    } catch (e) {
      print('Error fetching conditions: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConditions() async {
    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for conditions save: $nationalId');
    if (nationalId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
        );
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Map UI state to DB columns
      final data = {
        'national_id': nationalId,
        'hypertension': _selectedConditions['الضغط'] ?? false,
        'diabetes': _selectedConditions['السكر'] ?? false,
        'heart_failure': _selectedConditions['ضعف عضلة القلب'] ?? false,
        'coronary_artery_disease':
            _selectedConditions['امراض الشريان التاجي (ذبحة صدرية جلطة بالقلب)'] ??
            false,
        'liver_fibrosis': _selectedConditions['التليف الكبدي'] ?? false,
        'renal_failure': _selectedConditions['القصور الكلوي'] ?? false,
        'tumors': _selectedConditions['أورام'] ?? false,
        'brain_bleed': _selectedConditions['نزيف بالمخ / جلطة بالمخ'] ?? false,
        'hemiplegia': _selectedConditions['شلل نصفي / شلل رباعي'] ?? false,
        'neuro_psych': _selectedConditions['أمراض عصبية أو نفسية'] ?? false,
        'mouth_bleed': _selectedConditions['نزيف من الفم'] ?? false,
        'rectal_bleed': _selectedConditions['نزيف من فتحة الشرج'] ?? false,
        'stomach_ulcer':
            _selectedConditions['فرحة بالمعدة أو الإثنا عشر'] ?? false,
        'asthma': _selectedConditions['حساسية الصدر (الربو)'] ?? false,
        'tuberculosis': _selectedConditions['درن (سل)'] ?? false,
        'lung_fibrosis': _selectedConditions['تليف بالرئة'] ?? false,
        'autoimmune': _selectedConditions['أمراض مناعية'] ?? false,
        'chronic_blood_disease': _selectedConditions['أمراض دم مزمنة'] ?? false,
        'other_conditions': _selectedConditions['otherConditionText'] ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _supabaseService.client.from('conditions').upsert(data);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الحالات المرضية')));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving conditions: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ الحالات المرضية: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الحالات المرضية'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 36),
          onPressed: () => Navigator.of(context).maybePop(),
          color: Theme.of(context).colorScheme.onPrimary,
          tooltip: 'رجوع',
        ),
      ),
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
