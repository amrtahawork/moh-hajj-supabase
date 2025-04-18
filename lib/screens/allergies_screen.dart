import 'package:flutter/material.dart';

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

  void _addAllergy(TextEditingController controller) {
    if (controller.text.isNotEmpty) {
      setState(() {
        _selectedAllergies.add(controller.text);
        controller.clear();
        FocusScope.of(context).unfocus(); // Dismiss keyboard
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _selectedAllergies.remove(allergy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الحساسية',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.shade300,
        iconTheme: const IconThemeData(color: Colors.black87), // Ensure back button is visible
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView( // Use ListView for better scrolling with keyboard
            children: [
              const Text(
                'اختر أنواع الحساسية التي قد تكون لديك',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              _buildAllergyCategory(
                title: 'حساسية الأدوية',
                isSelected: _drugsAllergySelected,
                controller: _drugsController,
                onChanged: (value) {
                  setState(() {
                    _drugsAllergySelected = value ?? false;
                    if (!_drugsAllergySelected) _drugsController.clear(); // Clear text if unchecked
                  });
                },
                onAdd: () => _addAllergy(_drugsController),
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
                onAdd: () => _addAllergy(_foodController),
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
                onAdd: () => _addAllergy(_otherController),
                hintText: 'أضف حساسية أخرى',
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'الحساسية المختارة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              _selectedAllergies.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('لم يتم اختيار أي حساسية بعد.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    )
                  : Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _selectedAllergies
                          .map((allergy) => Chip(
                                label: Text(allergy, style: TextStyle(color: Colors.pink.shade900)),
                                deleteIcon: Icon(Icons.close, size: 18, color: Colors.pink.shade700),
                                onDeleted: () => _removeAllergy(allergy),
                                backgroundColor: Colors.pink.shade50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.pink.shade100)
                                ),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement actual save logic (e.g., save to database/storage)
                    print('Selected Allergies: $_selectedAllergies');
                    print('Drugs Allergy Selected: $_drugsAllergySelected, Details: ${_drugsController.text}');
                    print('Food Allergy Selected: $_foodAllergySelected, Details: ${_foodController.text}');
                    print('Other Allergy Selected: $_otherAllergySelected, Details: ${_otherController.text}');
                    Navigator.pop(context, _selectedAllergies); // Return the list of selected allergies
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Match image color
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('حفظ', style: TextStyle(color: Colors.white)),
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
    required VoidCallback onAdd,
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
           )
         ]
       ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            value: isSelected,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: Colors.pink, // Match image color
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
            dense: true,
          ),
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(right: 40.0, left: 16.0, bottom: 8.0), // Indent text field aligned with checkbox text
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add_circle_outline, color: Colors.pink.shade300),
                    onPressed: onAdd,
                    tooltip: 'إضافة',
                  ),
                  border: const UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink.shade300),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0)
                ),
                onSubmitted: (_) => onAdd(), // Add on submit
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