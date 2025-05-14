import 'package:flutter/material.dart';
import '../services/health_data_service.dart';

class MyMedicalInfoTab extends StatefulWidget {
  const MyMedicalInfoTab({super.key});

  @override
  State<MyMedicalInfoTab> createState() => _MyMedicalInfoTabState();
}

class _MyMedicalInfoTabState extends State<MyMedicalInfoTab> {
  final HealthDataService _service = HealthDataService();
  List<String> _apiConditions = [];
  List<String> _apiMedications = [];
  List<String> _apiAllergies = [];
  List<String> _apiOtherFactors = [];
  String _apiComments = '';
  bool _isLoading = true;

  // Added state for blood type
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
    _fetchAllMedicalInfo();
    _loadBloodType();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Refresh data when returning to this tab
  }

  Future<void> _fetchAllMedicalInfo() async {
    setState(() => _isLoading = true);
    try {
      // Initialize the health data service which will load data from Supabase
      await _service.init();
      
      setState(() {
        // Use data directly from the service which now comes from Supabase
        _apiConditions = _service.conditions.keys.toList();
        _apiMedications = _service.medications;
        // Note: If allergies is not implemented in the service, this might need adjustment
        _apiAllergies = [];
        _apiOtherFactors = _service.otherFactors;
        _apiComments = _service.comments;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching medical info: $e');
      setState(() {
        _apiConditions = _service.conditions.keys.toList();
        _apiMedications = _service.medications;
        _apiAllergies = [];
        _apiOtherFactors = _service.otherFactors;
        _apiComments = _service.comments;
        _isLoading = false;
      });
    }
  }

 
  Future<void> _loadBloodType() async {
   
  }

  // Added method to save blood type (example using shared_preferences)
  Future<void> _saveBloodType() async {
   
    print(
      'Saving Blood Type: $_selectedBloodType$_selectedRhFactor',
    ); // Placeholder
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
                        for (
                          int i = 0;
                          i < dialogBloodTypeSelection.length;
                          i++
                        ) {
                          dialogBloodTypeSelection[i] = i == index;
                        }
                        dialogSelectedBloodType = _bloodTypes[index];
                      });
                    },
                    children:
                        _bloodTypes
                            .map(
                              (type) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(type),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text('اختر عامل Rh'), // Arabic text
                  const SizedBox(height: 8),
                  ToggleButtons(
                    isSelected: dialogRhFactorSelection,
                    onPressed: (int index) {
                      setDialogState(() {
                        for (
                          int i = 0;
                          i < dialogRhFactorSelection.length;
                          i++
                        ) {
                          dialogRhFactorSelection[i] = i == index;
                        }
                        dialogSelectedRhFactor = _rhFactors[index];
                      });
                    },
                    children:
                        _rhFactors
                            .map(
                              (factor) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Text(factor),
                              ),
                            )
                            .toList(),
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
                    if (dialogSelectedBloodType != null &&
                        dialogSelectedRhFactor != null) {
                      setState(() {
                        _selectedBloodType = dialogSelectedBloodType;
                        _selectedRhFactor = dialogSelectedRhFactor;
                        _bloodTypeSelection.setAll(0, dialogBloodTypeSelection);
                        _rhFactorSelection.setAll(0, dialogRhFactorSelection);
                      });
                      _saveBloodType(); // Save the selection
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حفظ فصيلة الدم: $_selectedBloodType$_selectedRhFactor',
                          ),
                        ), // Arabic text
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء اختيار فصيلة الدم وعامل Rh'),
                        ), // Arabic text
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
    return Scaffold(
      appBar: AppBar(title: const Text('معلوماتي الطبية')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conditions
                    Text(
                      'الحالات الصحية:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_apiConditions.isEmpty)
                      const Text('لا توجد حالات صحية مسجلة.'),
                    ..._apiConditions.map((c) => ListTile(title: Text(c))),
                    const Divider(),
                    // Medications
                    Text(
                      'الأدوية:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_apiMedications.isEmpty)
                      const Text('لا توجد أدوية مسجلة.'),
                    ..._apiMedications.map((m) => ListTile(title: Text(m))),
                    const Divider(),
                    // Allergies
                    Text(
                      'الحساسية:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_apiAllergies.isEmpty)
                      const Text('لا توجد حساسية مسجلة.'),
                    ..._apiAllergies.map((a) => ListTile(title: Text(a))),
                    const Divider(),
                    // Other Factors
                    Text(
                      'عوامل أخرى:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_apiOtherFactors.isEmpty)
                      const Text('لا توجد عوامل أخرى مسجلة.'),
                    ..._apiOtherFactors.map((f) => ListTile(title: Text(f))),
                    const Divider(),
                    // Comments
                    Text(
                      'ملاحظات / تعليقات:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_apiComments.isEmpty)
                      const Text('لا توجد ملاحظات أو تعليقات.'),
                    if (_apiComments.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_apiComments),
                      ),
                  ],
                ),
              ),
    );
  }
}
