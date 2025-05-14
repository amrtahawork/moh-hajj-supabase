import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _userName = "اسم المستخدم";
  String _dateOfBirth = "01/01/1990";
  String _nationality = "الجنسية";
  String _passportNumber = "AB1234567";
  String _nationalId = "1234567890";

  @override
  void initState() {
    super.initState();
    _fetchProfileFromSupabase();
  }

  Future<void> _fetchProfileFromSupabase() async {
    try {
      final supabaseService = SupabaseService();
      final userData = await supabaseService.getUserData();
      if (userData != null && userData['user_profile'] != null) {
        final profileData = userData['user_profile'];
        setState(() {
          _userName = profileData['userName'] ?? _userName;
          _dateOfBirth = profileData['dateOfBirth'] ?? _dateOfBirth;
          _nationality = profileData['nationality'] ?? _nationality;
          _passportNumber = profileData['passportNumber'] ?? _passportNumber;
          _nationalId = profileData['nationalId'] ?? _nationalId;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('فشل في جلب بيانات الملف الشخصي من قاعدة البيانات'),
            ),
          );
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('خطأ في الاتصال بقاعدة البيانات')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileInfoItem(label: 'الاسم', value: _userName),
            const Divider(),
            _buildProfileInfoItem(label: 'تاريخ الميلاد', value: _dateOfBirth),
            const Divider(),
            _buildProfileInfoItem(label: 'الجنسية', value: _nationality),
            const Divider(),
            _buildProfileInfoItem(
              label: 'رقم الهوية الوطنية/الإقامة',
              value: _nationalId,
            ),
            const Divider(),
            _buildProfileInfoItem(
              label: 'رقم جواز السفر',
              value: _passportNumber,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoItem({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
