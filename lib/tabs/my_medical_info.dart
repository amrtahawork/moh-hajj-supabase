import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // For AppUser
import '../services/supabase_medical_info_service.dart';

class MyMedicalInfoTab extends StatefulWidget {
  final void Function(int)? onTabChange;
  const MyMedicalInfoTab({super.key, this.onTabChange});

  @override
  State<MyMedicalInfoTab> createState() => _MyMedicalInfoTabState();
}

class _MyMedicalInfoTabState extends State<MyMedicalInfoTab> {
  final SupabaseMedicalInfoService _medicalInfoService =
      SupabaseMedicalInfoService();
  MedicalInfo? _medicalInfo;
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
      final String? nationalId = AppUser.currentUserId;
      if (nationalId == null) {
        setState(() {
          _medicalInfo = null;
          _isLoading = false;
        });
        return;
      }
      final info = await _medicalInfoService.fetchMedicalInfo(nationalId);
      setState(() {
        _medicalInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching medical info: $e');
      setState(() {
        _medicalInfo = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadBloodType() async {
    try {
      final SupabaseService supabaseService = SupabaseService();
      final String? nationalId = AppUser.currentUserId;
      if (nationalId == null) return;
      final bloodTypeData = await supabaseService.getBloodTypeFromProfile(
        nationalId,
      );
      if (bloodTypeData != null) {
        setState(() {
          _selectedBloodType = bloodTypeData['blood_type'];
          _selectedRhFactor = bloodTypeData['rh_factor'];
          // Update toggle selections
          if (_selectedBloodType != null) {
            int bloodIndex = _bloodTypes.indexOf(_selectedBloodType!);
            if (bloodIndex != -1) {
              for (int i = 0; i < _bloodTypeSelection.length; i++) {
                _bloodTypeSelection[i] = i == bloodIndex;
              }
            }
          }
          if (_selectedRhFactor != null) {
            int rhIndex = _rhFactors.indexOf(_selectedRhFactor!);
            if (rhIndex != -1) {
              for (int i = 0; i < _rhFactorSelection.length; i++) {
                _rhFactorSelection[i] = i == rhIndex;
              }
            }
          }
        });
      }
    } catch (e) {
      print('Error loading blood type: $e');
    }
  }

  // Save blood type using SupabaseService
  Future<void> _saveBloodType() async {
    if (_selectedBloodType == null || _selectedRhFactor == null) return;
    try {
      final SupabaseService supabaseService = SupabaseService();
      final String? nationalId = AppUser.currentUserId;
      if (nationalId == null) return;
      final success = await supabaseService.saveBloodTypeToProfile(
        nationalId: nationalId,
        bloodType: _selectedBloodType!,
        rhFactor: _selectedRhFactor!,
      );
      if (success) {
        print(
          'Blood type saved successfully: $_selectedBloodType$_selectedRhFactor',
        );
      } else {
        print('Failed to save blood type');
      }
    } catch (e) {
      print('Error saving blood type: $e');
    }
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

  bool _isValidUuid(String uuid) {
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(uuid);
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلوماتي الطبية'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        leading:
            (widget.onTabChange != null)
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, size: 36),
                  onPressed: () => widget.onTabChange!(0),
                  color: theme.colorScheme.onPrimary,
                  tooltip: 'رجوع',
                )
                : (Navigator.of(context).canPop()
                    ? IconButton(
                      icon: const Icon(Icons.arrow_back, size: 36),
                      onPressed: () => Navigator.of(context).maybePop(),
                      color: theme.colorScheme.onPrimary,
                      tooltip: 'رجوع',
                    )
                    : null),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Blood type card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: ListTile(
                        leading: Icon(
                          Icons.bloodtype,
                          color: theme.colorScheme.primary,
                        ),
                        title: const Text(
                          'فصيلة الدم',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _selectedBloodType != null &&
                                  _selectedRhFactor != null
                              ? '${_selectedBloodType!}${_selectedRhFactor!}'
                              : 'غير محددة',
                          style: theme.textTheme.titleLarge,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: _showBloodTypeDialog,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Conditions
                    _buildSectionCard(
                      icon: Icons.health_and_safety,
                      title: 'الحالات الصحية',
                      children:
                          _medicalInfo!.selectedConditions.isEmpty
                              ? [const Text('لا توجد حالات صحية مسجلة.')]
                              : [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _medicalInfo!.selectedConditions
                                          .map(
                                            (c) => Chip(
                                              label: Text(c),
                                              backgroundColor:
                                                  theme
                                                      .colorScheme
                                                      .secondaryContainer,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                    ),
                    const SizedBox(height: 16),
                    // Medications
                    _buildSectionCard(
                      icon: Icons.medication,
                      title: 'الأدوية',
                      children:
                          _medicalInfo!.medications.isEmpty
                              ? [const Text('لا توجد أدوية مسجلة.')]
                              : [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _medicalInfo!.medications
                                          .map(
                                            (m) => Chip(
                                              label: Text(m),
                                              backgroundColor:
                                                  theme
                                                      .colorScheme
                                                      .secondaryContainer,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                    ),
                    const SizedBox(height: 16),
                    // Allergies
                    _buildSectionCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'الحساسية',
                      children:
                          _medicalInfo!.allergies.isEmpty
                              ? [const Text('لا توجد حساسية مسجلة.')]
                              : [
                                if (_medicalInfo!.allergies['drugs_allergy'] ==
                                    true)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.check,
                                      color: Colors.pink,
                                    ),
                                    title: const Text('حساسية الأدوية'),
                                    subtitle:
                                        _medicalInfo!.allergies['drugs_details']
                                                .toString()
                                                .isNotEmpty
                                            ? Text(
                                              _medicalInfo!
                                                  .allergies['drugs_details'],
                                            )
                                            : null,
                                  ),
                                if (_medicalInfo!.allergies['food_allergy'] ==
                                    true)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.check,
                                      color: Colors.pink,
                                    ),
                                    title: const Text('حساسية الطعام'),
                                    subtitle:
                                        _medicalInfo!.allergies['food_details']
                                                .toString()
                                                .isNotEmpty
                                            ? Text(
                                              _medicalInfo!
                                                  .allergies['food_details'],
                                            )
                                            : null,
                                  ),
                                if (_medicalInfo!.allergies['other_allergy'] ==
                                    true)
                                  ListTile(
                                    leading: const Icon(
                                      Icons.check,
                                      color: Colors.pink,
                                    ),
                                    title: const Text('حساسيات أخرى'),
                                    subtitle:
                                        _medicalInfo!.allergies['other_details']
                                                .toString()
                                                .isNotEmpty
                                            ? Text(
                                              _medicalInfo!
                                                  .allergies['other_details'],
                                            )
                                            : null,
                                  ),
                              ],
                    ),
                    const SizedBox(height: 16),
                    // Other Factors
                    _buildSectionCard(
                      icon: Icons.info_outline,
                      title: 'عوامل أخرى',
                      children:
                          _medicalInfo!.selectedOtherFactors.isEmpty
                              ? [const Text('لا توجد عوامل أخرى مسجلة.')]
                              : [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _medicalInfo!.selectedOtherFactors
                                          .map(
                                            (f) => Chip(
                                              label: Text(f),
                                              backgroundColor:
                                                  theme
                                                      .colorScheme
                                                      .secondaryContainer,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                    ),
                    const SizedBox(height: 16),
                    // Comments
                    _buildSectionCard(
                      icon: Icons.comment,
                      title: 'ملاحظات',
                      children:
                          _medicalInfo!.comments.isEmpty
                              ? [const Text('لا توجد ملاحظات مسجلة.')]
                              : [Text(_medicalInfo!.comments)],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
