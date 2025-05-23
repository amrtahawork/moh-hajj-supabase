import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImportantNumbersAddressesTab extends StatelessWidget {
  final void Function(int)? onTabChange;
  const ImportantNumbersAddressesTab({super.key, this.onTabChange});

  Future<void> _copyToClipboard(
    String phoneNumber,
    BuildContext context,
  ) async {
    // تنسيق رقم الهاتف بشكل صحيح
    final formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    try {
      // نسخ الرقم إلى الحافظة
      await Clipboard.setData(ClipboardData(text: formattedNumber));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم نسخ الرقم $phoneNumber إلى الحافظة'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ أثناء محاولة نسخ الرقم. يرجى المحاولة مرة أخرى',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الأرقام والعناوين المهمة',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          elevation: 0,
          leading:
              (onTabChange != null)
                  ? IconButton(
                    icon: const Icon(Icons.arrow_back, size: 36),
                    onPressed: () => onTabChange!(0),
                    color: Theme.of(context).colorScheme.onPrimary,
                    tooltip: 'رجوع',
                  )
                  : (Navigator.of(context).canPop()
                      ? IconButton(
                        icon: const Icon(Icons.arrow_back, size: 36),
                        onPressed: () => Navigator.of(context).maybePop(),
                        color: Theme.of(context).colorScheme.onPrimary,
                        tooltip: 'رجوع',
                      )
                      : null),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Updated Emergency Numbers Section
              const Text(
                'مكة المكرمة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy, color: Colors.green),
                title: const Text('0560669002'),
                onTap: () => _copyToClipboard('0560669002', context),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy, color: Colors.green),
                title: const Text('0560380820'),
                onTap: () => _copyToClipboard('0560380820', context),
              ),
              const SizedBox(height: 8),
              const Text(
                'المدينة المنورة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              ListTile(
                leading: const Icon(Icons.content_copy, color: Colors.green),
                title: const Text('0549712001'),
                onTap: () => _copyToClipboard('0549712001', context),
              ),
              const SizedBox(height: 16),

              // Hospitals Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.local_hospital, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'المستشفيات وتخصصاتها',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildHospitalTile('مستشفى الملك فيصل', [
                        'غسيل كلوي',
                        'جميع التخصصات',
                      ]),
                      _buildHospitalTile('مستشفى النور التخصصي', [
                        'غسيل كلوي',
                        'جميع التخصصات',
                      ]),
                      _buildHospitalTile('مستشفى الملك عبد العزيز', [
                        'غسيل كلوي',
                        'مخ وأعصاب',
                        'عظام',
                        'جراحة',
                      ]),
                      _buildHospitalTile('مستشفى حراء العام', [
                        'رعاية مركزة',
                        'باطنة',
                        'جراحة',
                        'رمد',
                        'أطفال',
                        'نساء وولادة',
                      ]),
                      _buildHospitalTile('مدينة الملك عبد الله الطبية', [
                        'قلب',
                        'أورام',
                      ]),
                      _buildHospitalTile('مستشفى الولادة والأطفال', [
                        'أطفال',
                        'نساء وولادة',
                      ]),
                      _buildHospitalTile('مستشفى طوارئ أجياد', [
                        'طوارئ',
                        'رعاية مركزة',
                      ]),
                      _buildHospitalTile('مستشفى طوارئ الحرم', ['طوارئ']),
                      _buildHospitalTile('عيادات الحرم (1-2-3)', ['طوارئ']),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Makkah Clinics Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.medical_services, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'عيادات مكة المكرمة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildClinicSection('عيادات فنادق حجاج القرعة', [
                        'الماسة بدر (٢ عيادة)',
                        'نزيل المشاعر',
                        'مأثر الجوار',
                        'الماسة جراند (٢ عيادة)',
                        'الماسة دار الفائزين',
                        'ميسان المقام',
                        'درة الصلاح',
                        'بكة رويال',
                        'افرند الجزيرة',
                      ]),
                      const SizedBox(height: 16),
                      _buildClinicSection('عيادات فنادق حجاج التضامن', [
                        'اعمار جراند',
                        'اعمار اندلسية',
                        'فوكو انتركونتننتال',
                        'العليان الذهبي',
                        'رويال جراند',
                        'أبراج مكة',
                      ]),
                      const SizedBox(height: 16),
                      _buildClinicSection('عيادات فنادق حجاج السياحة', [
                        'الصفوة',
                        'عيادات اعمار جراند',
                        'عيادة أمراض القلب',
                        'عيادة أمراض الصدر',
                        'عيادة أمراض الباطنة والحميات',
                        'العيادة الرابعة صباحا الرمد',
                        'الشفت التاني أمراض النسا',
                        'الشفت الثالث باطنة',
                      ]),
                      const SizedBox(height: 8),
                      const Text(
                        'بالإضافة إلى ٣ عيادات بالتنسيق مع بعثة السياحة في الشقق الفندقية',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalTile(String name, List<String> specialties) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            children:
                specialties
                    .map(
                      (specialty) => Chip(
                        label: Text(
                          specialty,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue.shade50,
                      ),
                    )
                    .toList(),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildClinicSection(String title, List<String> clinics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...clinics.map(
          (clinic) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(clinic)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
