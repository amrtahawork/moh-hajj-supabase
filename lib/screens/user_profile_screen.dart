import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser
import 'package:flutter/services.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _userName = "اسم المستخدم";
  String _dateOfBirth = "01/01/1990";
  String _nationality = "المحافظة";
  String _passportNumber = "AB1234567";
  String _nationalId = "1234567890";
  bool _isLoading = false;

  // Editable fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _altPhoneController = TextEditingController();
  final TextEditingController _hotelController = TextEditingController();
  final TextEditingController _jobController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileFromSupabase();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _altPhoneController.dispose();
    _hotelController.dispose();
    _jobController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProfileFromSupabase();
  }

  Future<void> _fetchProfileFromSupabase() async {
    setState(() {
      _isLoading = true;
    });

    String? userId = AppUser.currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      if (AppUser.profile != null) {
        setState(() {
          _userName = AppUser.profile!['user_name'] ?? _userName;
          _dateOfBirth = AppUser.profile!['birth_date'] ?? _dateOfBirth;
          _nationality = AppUser.profile!['nationality'] ?? _nationality;
          _passportNumber =
              AppUser.profile!['passport_number'] ?? _passportNumber;
          _nationalId = AppUser.profile!['national_id'] ?? _nationalId;
          _phoneController.text = AppUser.profile!['phone'] ?? '';
          _altPhoneController.text = AppUser.profile!['alt_phone'] ?? '';
          _hotelController.text = AppUser.profile!['hotel_name'] ?? '';
          _jobController.text = AppUser.profile!['job'] ?? '';
          _roomController.text = AppUser.profile!['room_number'] ?? '';
        });
      } else {
        final data =
            await SupabaseService().client
                .from('user_profile')
                .select()
                .eq('user_id', userId)
                .maybeSingle();

        if (data != null) {
          setState(() {
            _userName = data['name'] ?? _userName;
            _dateOfBirth = data['birth_date'] ?? _dateOfBirth;
            _nationality = data['nationality'] ?? _nationality;
            _passportNumber = data['passport_number'] ?? _passportNumber;
            _nationalId = data['national_id'] ?? _nationalId;
            _phoneController.text = data['phone'] ?? '';
            _altPhoneController.text = data['alt_phone'] ?? '';
            _hotelController.text = data['hotel_name'] ?? '';
            _jobController.text = data['job'] ?? '';
            _roomController.text = data['room_number'] ?? '';
            AppUser.profile = data;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEditableFields() async {
    // Validation for phone and room number fields
    final phoneRegExp = RegExp(r'^\d{8,15} ?$'); // Accepts 8-15 digits
    final roomRegExp = RegExp(r'^\d{1,6} ?$'); // Accepts 1-6 digits
    if (!phoneRegExp.hasMatch(_phoneController.text) ||
        (_altPhoneController.text.isNotEmpty &&
            !phoneRegExp.hasMatch(_altPhoneController.text)) ||
        (_roomController.text.isNotEmpty &&
            !roomRegExp.hasMatch(_roomController.text))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال أرقام صحيحة فقط في حقول الهاتف والغرفة'),
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      String? userId = AppUser.currentUserId;
      if (userId == null) throw Exception('User not logged in');
      
      // Create updated data map
      final updatedData = {
        'phone': _phoneController.text,
        'alt_phone': _altPhoneController.text,
        'hotel_name': _hotelController.text,
        'job': _jobController.text,
        'room_number': _roomController.text,
      };
      
      // Update in Supabase
      await SupabaseService().client
          .from('user_profile')
          .update(updatedData)
          .eq('national_id', _nationalId);
      
      // Update local AppUser.profile data immediately
      if (AppUser.profile != null) {
        AppUser.profile!['phone'] = _phoneController.text;
        AppUser.profile!['alt_phone'] = _altPhoneController.text;
        AppUser.profile!['hotel_name'] = _hotelController.text;
        AppUser.profile!['job'] = _jobController.text;
        AppUser.profile!['room_number'] = _roomController.text;
      }
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح')));
      
      // No need to fetch profile data again since we've updated locally
      setState(() {}); // Trigger UI refresh with updated data
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في حفظ البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      floatingActionButton:
          _isLoading
              ? null
              : FloatingActionButton.extended(
                onPressed: _saveEditableFields,
                icon: const Icon(Icons.save),
                label: const Text('حفظ البيانات'),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Modern header with user name only (no avatar, no national ID)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _userName,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Profile info cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildInfoCard(
                            icon: Icons.badge,
                            label: 'رقم البطاقة الشخصية',
                            value: _nationalId,
                          ),
                          _buildInfoCard(
                            icon: Icons.book,
                            label: 'رقم جواز السفر',
                            value: _passportNumber,
                          ),
                          _buildEditableCard(
                            icon: Icons.phone_android,
                            label: 'رقم الهاتف الشخصي',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildEditableCard(
                            icon: Icons.phone,
                            label:
                                'رقم آخر للاتصال في حال تعذر الوصول للرقم الشخصي',
                            controller: _altPhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildEditableCard(
                            icon: Icons.hotel,
                            label: 'اسم الفندق',
                            controller: _hotelController,
                          ),
                          _buildEditableCard(
                            icon: Icons.work,
                            label: 'job',
                            controller: _jobController,
                          ),
                          _buildEditableCard(
                            icon: Icons.meeting_room,
                            label: 'رقم الغرفة',
                            controller: _roomController,
                          ),
                          const SizedBox(height: 80), // For FAB space
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value, style: theme.textTheme.bodyLarge),
        tileColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  Widget _buildEditableCard({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    // Determine if this is a phone or room number field
    final isPhone = label.contains('هاتف') || label.contains('رقم آخر');
    final isRoom = label.contains('غرفة');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    inputFormatters:
                        isPhone || isRoom
                            ? [FilteringTextInputFormatter.digitsOnly]
                            : null,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}