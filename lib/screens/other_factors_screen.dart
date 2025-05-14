import 'package:flutter/material.dart';
import '../services/health_data_service.dart';

class OtherFactorsScreen extends StatefulWidget {
  const OtherFactorsScreen({super.key});

  @override
  State<OtherFactorsScreen> createState() => _OtherFactorsScreenState();
}

class _OtherFactorsScreenState extends State<OtherFactorsScreen> {
  final List<String> _factors = [
    'تم حجزك في مستشفى',
    'تم حجزك في رعاية مركزة',
    'أجريت لك عملية جراحية',
    'أجريت لك قسطرة قلبية أو مخية',
    'أجريت لك جلسات غسيل كلوي',
    'أجريت لك جلسات علاج كيماوي/إشعاعي',
    'أجري لك منظار جهاز هضمي',
    'أجري لك منظار آخر (أذكر نوعه)',
    'تمت لك إجراءات أخرى (أذكرها)',
  ];
  final HealthDataService _service = HealthDataService();
  final TextEditingController _detailsController = TextEditingController();
  bool _showDetailsField = false;
  String _savedDetails = '';

  @override
  void initState() {
    super.initState();
    _showDetailsField =
        _service.otherFactors.contains('أجري لك منظار آخر (أذكر نوعه)') ||
        _service.otherFactors.contains('تمت لك إجراءات أخرى (أذكرها)');
    // Load saved details if any
    _savedDetails =
        _service.otherFactors.contains('details:')
            ? _service.otherFactors
                .firstWhere((f) => f.startsWith('details:'), orElse: () => '')
                .replaceFirst('details:', '')
            : '';
    _detailsController.text = _savedDetails;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  void _onFactorChanged(String factor, bool value) {
    setState(() {
      if (value) {
        _service.addOtherFactor(factor);
      } else {
        _service.removeOtherFactor(factor);
      }
      _showDetailsField =
          _service.otherFactors.contains('أجري لك منظار آخر (أذكر نوعه)') ||
          _service.otherFactors.contains('تمت لك إجراءات أخرى (أذكرها)');
    });
  }

  Future<void> _saveData() async {
    // Save details locally as a special factor
    if (_showDetailsField && _detailsController.text.trim().isNotEmpty) {
      // Remove any previous details
      _service.otherFactors.removeWhere((f) => f.startsWith('details:'));
      _service.addOtherFactor('details:${_detailsController.text.trim()}');
    } else {
      _service.otherFactors.removeWhere((f) => f.startsWith('details:'));
    }
    setState(() {
      _savedDetails = _detailsController.text.trim();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حفظ المعلومات محلياً')));
    // Save to Supabase
    final apiSuccess = await _service.saveUserData(
      'other-factors',
      {
        'factors': _service.otherFactors
            .where((f) => !f.startsWith('details:'))
            .toList(),
        if (_showDetailsField && _detailsController.text.trim().isNotEmpty)
          'details': _detailsController.text.trim(),
      },
    );
    if (apiSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ المعلومات في Supabase')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ المعلومات في Supabase')),
      );
    }
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
                      ..._factors.map(
                        (factor) => CheckboxListTile(
                          title: Text(factor),
                          value: _service.otherFactors.contains(factor),
                          onChanged:
                              (val) => _onFactorChanged(factor, val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      ),
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
}
