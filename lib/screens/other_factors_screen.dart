import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser

class OtherFactorsScreen extends StatefulWidget {
  const OtherFactorsScreen({super.key});

  @override
  State<OtherFactorsScreen> createState() => _OtherFactorsScreenState();
}

class _OtherFactorsScreenState extends State<OtherFactorsScreen> {
  final List<Map<String, dynamic>> _factors = [
    {'label': 'تم حجزك في مستشفى', 'key': 'hospitalized'},
    {'label': 'تم حجزك في رعاية مركزة', 'key': 'icu'},
    {'label': 'أجريت لك عملية جراحية', 'key': 'surgery'},
    {'label': 'أجريت لك قسطرة قلبية أو محية', 'key': 'cardiac_catheterization'},
    {'label': 'أجريت لك جلسات غسيل كلوي', 'key': 'dialysis'},
    {'label': 'أجريت لك جلسات علاج كيماوي/إشعاعي', 'key': 'chemo_radiation'},
    {'label': 'أجري لك منظار جهاز هضمي', 'key': 'gi_endoscopy'},
    {
      'label': 'أجري لك منظار آخر (أذكر نوعه)',
      'key': 'other_endoscopy',
      'detailsKey': 'other_endoscopy_details',
    },
    {
      'label': 'تمت لك إجراءات أخرى (أذكرها)',
      'key': 'other_procedure',
      'detailsKey': 'other_procedure_details',
    },
  ];

  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  Map<String, bool> _selectedFactors = {};
  Map<String, TextEditingController> _detailsControllers = {};

  @override
  void initState() {
    super.initState();
    for (var factor in _factors) {
      _selectedFactors[factor['key']] = false;
      if (factor.containsKey('detailsKey')) {
        _detailsControllers[factor['detailsKey']] = TextEditingController();
      }
    }
    _fetchFactors();
  }

  @override
  void dispose() {
    for (var controller in _detailsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchFactors() async {
    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for other factors fetch: $nationalId');
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
              .from('other_factors')
              .select()
              .eq('national_id', nationalId)
              .maybeSingle();

      if (data != null) {
        setState(() {
          for (var factor in _factors) {
            _selectedFactors[factor['key']] = data[factor['key']] ?? false;
            if (factor.containsKey('detailsKey')) {
              _detailsControllers[factor['detailsKey']]?.text =
                  data[factor['detailsKey']] ?? '';
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching other factors: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveFactors() async {
    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for other factors save: $nationalId');
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
      final Map<String, dynamic> data = {
        'national_id': nationalId,
        'updated_at': DateTime.now().toIso8601String(),
      };
      for (var factor in _factors) {
        data[factor['key']] = _selectedFactors[factor['key']] ?? false;
        if (factor.containsKey('detailsKey')) {
          data[factor['detailsKey']] =
              _detailsControllers[factor['detailsKey']]?.text ?? '';
        }
      }
      await _supabaseService.client.from('other_factors').upsert(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ العوامل الأخرى')));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving other factors: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ العوامل الأخرى: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFactorChanged(String key, bool value) {
    setState(() {
      _selectedFactors[key] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'عوامل أخرى',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
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
                      ..._factors.map(
                        (factor) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CheckboxListTile(
                              title: Text(factor['label']),
                              value: _selectedFactors[factor['key']] ?? false,
                              onChanged:
                                  (val) => _onFactorChanged(
                                    factor['key'],
                                    val ?? false,
                                  ),
                              controlAffinity: ListTileControlAffinity.leading,
                              dense: true,
                            ),
                            if (factor.containsKey('detailsKey') &&
                                (_selectedFactors[factor['key']] ?? false))
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 0,
                                ),
                                child: TextField(
                                  controller:
                                      _detailsControllers[factor['detailsKey']],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'أدخل التفاصيل هنا...',
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFactors,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
