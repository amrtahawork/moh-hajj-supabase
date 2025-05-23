import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  bool _drugsAllergySelected = false;
  bool _foodAllergySelected = false;
  bool _otherAllergySelected = false;

  final TextEditingController _drugsController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _otherController = TextEditingController();

  final List<String> _selectedAllergies = [];
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAllergyData();
  }

  Future<void> _fetchAllergyData() async {
    setState(() {
      _isLoading = true;
    });
    String? nationalId = AppUser.currentUserId;
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
      final response =
          await _supabaseService.client
              .from('allergies')
              .select()
              .eq('national_id', nationalId)
              .limit(1)
              .maybeSingle();
      if (response != null) {
        setState(() {
          _drugsAllergySelected = response['drugs_allergy'] ?? false;
          _foodAllergySelected = response['food_allergy'] ?? false;
          _otherAllergySelected = response['other_allergy'] ?? false;
          _drugsController.text = response['drugs_details'] ?? '';
          _foodController.text = response['food_details'] ?? '';
          _otherController.text = response['other_details'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching allergy data: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تحميل بيانات الحساسية: $e')),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAllergyData() async {
    setState(() {
      _isLoading = true;
    });
    String? nationalId = AppUser.currentUserId;
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
      await _supabaseService.client.from('allergies').upsert({
        'national_id': nationalId,
        'drugs_allergy': _drugsAllergySelected,
        'drugs_details': _drugsController.text,
        'food_allergy': _foodAllergySelected,
        'food_details': _foodController.text,
        'other_allergy': _otherAllergySelected,
        'other_details': _otherController.text,
        'updated_at': DateTime.now().toIso8601String(),
      }, ignoreDuplicates: false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات الحساسية')));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving allergy: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ بيانات الحساسية: $e')));
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
        title: const Text(
          'الحساسية',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 1,
        shadowColor: Colors.grey.shade300,
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
          child: ListView(
            // Use ListView for better scrolling with keyboard
            children: [
              const Text(
                'اختر أنواع الحساسية التي قد تكون لديك',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              _buildAllergyCategory(
                title: 'حساسية الأدوية',
                isSelected: _drugsAllergySelected,
                controller: _drugsController,
                onChanged: (value) {
                  setState(() {
                    _drugsAllergySelected = value ?? false;
                    if (!_drugsAllergySelected)
                      _drugsController.clear(); // Clear text if unchecked
                  });
                },
                hintText: 'أضف حساسية دواء',
              ),
              const SizedBox(height: 16),
              _buildAllergyCategory(
                title: 'حساسية الطعام',
                isSelected: _foodAllergySelected,
                controller: _foodController,
                onChanged: (value) {
                  setState(() {
                    _foodAllergySelected = value ?? false;
                    if (!_foodAllergySelected) _foodController.clear();
                  });
                },
                hintText: 'أضف حساسية طعام',
              ),
              const SizedBox(height: 16),
              _buildAllergyCategory(
                title: 'حساسيات أخرى',
                isSelected: _otherAllergySelected,
                controller: _otherController,
                onChanged: (value) {
                  setState(() {
                    _otherAllergySelected = value ?? false;
                    if (!_otherAllergySelected) _otherController.clear();
                  });
                },
                hintText: 'أضف حساسية أخرى',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAllergyData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Match image color
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'حفظ',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ),
              const SizedBox(height: 20), // Add some padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllergyCategory({
    required String title,
    required bool isSelected,
    required TextEditingController controller,
    required ValueChanged<bool?> onChanged,
    required String hintText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            value: isSelected,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.pink, // Match image color
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            dense: true,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(
                right: 40.0,
                left: 16.0,
                bottom: 8.0,
              ), // Indent text field aligned with checkbox text
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: const UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink.shade300),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _drugsController.dispose();
    _foodController.dispose();
    _otherController.dispose();
    super.dispose();
  }
}
