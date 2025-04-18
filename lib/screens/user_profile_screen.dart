import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Import dart:io for File type
import 'dart:convert'; // For JSON encoding/decoding
import 'package:path_provider/path_provider.dart'; // For file path

// Convert to StatefulWidget to potentially handle data loading/editing later
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  // Placeholder data - replace with actual user data retrieval
  // Make variables non-final to allow editing
  String _userName = "اسم المستخدم";
  String _dateOfBirth = "01/01/1990";
  String _nationality = "الجنسية";
  String _passportNumber = "AB1234567";
  String _nationalId = "1234567890";
  File? _profileImage; // Variable to hold the selected image file

  final ImagePicker _picker = ImagePicker(); // Image picker instance
  static const _profileFileName = 'profile.json';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<String> _getProfileFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$_profileFileName';
  }

  Future<void> _saveProfile() async {
    final filePath = await _getProfileFilePath();
    final data = {
      'userName': _userName,
      'dateOfBirth': _dateOfBirth,
      'nationality': _nationality,
      'passportNumber': _passportNumber,
      'nationalId': _nationalId,
      'profileImagePath': _profileImage?.path,
    };
    final file = File(filePath);
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _loadProfile() async {
    try {
      final filePath = await _getProfileFilePath();
      final file = File(filePath);
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        final data = jsonDecode(jsonStr);
        setState(() {
          _userName = data['userName'] ?? _userName;
          _dateOfBirth = data['dateOfBirth'] ?? _dateOfBirth;
          _nationality = data['nationality'] ?? _nationality;
          _passportNumber = data['passportNumber'] ?? _passportNumber;
          _nationalId = data['nationalId'] ?? _nationalId;
          final imgPath = data['profileImagePath'];
          if (imgPath != null && imgPath is String && imgPath.isNotEmpty) {
            _profileImage = File(imgPath);
          }
        });
      }
    } catch (e) {
      // Ignore errors, use defaults
    }
  }

  // Function to pick an image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _saveProfile();
    }
  }

  // Helper to show a date picker and update date of birth
  Future<void> _pickDateOfBirth() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth.isNotEmpty
          ? _parseDate(_dateOfBirth) ?? DateTime(1990, 1, 1)
          : DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = _formatDate(picked);
      });
      await _saveProfile();
    }
  }

  // Helper to parse date from string
  DateTime? _parseDate(String date) {
    try {
      final parts = date.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  // Helper to format date as dd/MM/yyyy
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي الشخصي'),
        centerTitle: true,
        backgroundColor: Colors.white, // Match other screens
        foregroundColor: Colors.black, // Match other screens
        elevation: 1, // Add subtle elevation
      ),
      body: ListView(
        // Use ListView for scrollable content
        padding: const EdgeInsets.all(20.0), // Increased padding
        children: <Widget>[
          const SizedBox(height: 20),
          // --- Profile Picture Section ---
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _profileImage != null
                          ? FileImage(_profileImage!) // Display selected image
                          : null, // No default asset image for now
                  child:
                      _profileImage == null
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey[400],
                          )
                          : null,
                ),
                Material(
                  // Wrap IconButton for ink splash effect
                  color: Theme.of(context).colorScheme.primary,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                    onPressed: _pickImage, // Call image picker
                    tooltip: 'Change profile picture',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30), // Spacing
          // --- Profile Info Section ---
          _buildProfileInfoItem(
            label: 'الاسم',
            value: _userName,
            onEdit:
                () => _showEditDialog('الاسم', _userName, (newValue) {
                  setState(() => _userName = newValue);
                }),
          ),
          const Divider(),
          _buildProfileInfoItem(
            label: 'تاريخ الميلاد',
            value: _dateOfBirth,
            onEdit: _pickDateOfBirth,
          ),
          const Divider(),
          _buildProfileInfoItem(
            label: 'الجنسية',
            value: _nationality,
            onEdit:
                () => _showEditDialog('الجنسية', _nationality, (newValue) {
                  setState(() => _nationality = newValue);
                }),
          ),
          const Divider(),
          _buildProfileInfoItem(
            label: 'رقم الهوية الوطنية/الإقامة',
            value: _nationalId,
            onEdit:
                () => _showEditDialog(
                  'رقم الهوية الوطنية/الإقامة',
                  _nationalId,
                  (newValue) {
                    setState(() => _nationalId = newValue);
                  },
                ),
          ),
          const Divider(),
          _buildProfileInfoItem(
            label: 'رقم جواز السفر',
            value: _passportNumber,
            onEdit:
                () => _showEditDialog('رقم جواز السفر', _passportNumber, (
                  newValue,
                ) {
                  setState(() => _passportNumber = newValue);
                }),
          ),
          // Add more profile items as needed
        ],
      ),
    );
  }

  // Helper widget to build consistent list items - Now uses ListTile
  Widget _buildProfileInfoItem({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600, // Slightly bolder
          color: Colors.grey[700],
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.edit_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: onEdit,
        tooltip: 'Edit $label',
      ),
    );
  }

  // --- Edit Dialog ---
  Future<void> _showEditDialog(
    String label,
    String currentValue,
    Function(String) onSave,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تعديل $label'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: label,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حفظ'),
              onPressed: () async {
                onSave(controller.text);
                await _saveProfile();
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ), // Modern rounded corners
        );
      },
    );
  }
}
