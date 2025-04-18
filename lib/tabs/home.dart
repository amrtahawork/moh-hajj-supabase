import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../screens/health_pdfs_screen.dart';
import '../screens/user_profile_screen.dart'; // Import the new screen

class Home extends StatelessWidget {
  final Function(int)? onTabChange;

  const Home({super.key, this.onTabChange});

  @override
  Widget build(BuildContext context) {
    String qrData = "User Medical Data Placeholder";

    return Directionality(
      textDirection: TextDirection.rtl, // Force RTL directionality
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Change to start for RTL
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'مرحباً بك',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const Text(
                'الخدمات الصحية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildGlassCard(
                    context,
                    color: Colors.lightBlue.shade100,
                    onTap: () {},
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        QrImageView(
                          data: qrData,
                          version: QrVersions.auto,
                          size: 80.0,
                          gapless: false,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ملفي الصحي',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  _buildGlassCard(
                    context,
                    color: Colors.amber.shade100,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HealthPdfsScreen(),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.picture_as_pdf, size: 40, color: Colors.black87),
                        SizedBox(height: 12),
                        Text(
                          'منشورات وزارة الصحة',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  _buildGlassCard(
                    context,
                    color: Colors.green.shade100,
                    onTap: () {
                      // Navigate to the new UserProfileScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const UserProfileScreen()),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_outline, size: 40, color: Colors.black87),
                        SizedBox(height: 12),
                        Text(
                          'ملفي الشخصي',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  _buildGlassCard(
                    context,
                    color: Colors.orange.shade100,
                    onTap: () {
                      if (onTabChange != null) {
                        onTabChange!(3);
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.phone, size: 40, color: Colors.black87),
                        SizedBox(height: 12),
                        Text(
                          'أرقام الطوارئ',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'تقارير صحية',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              _buildHorizontalCard(
                context,
                title: 'فحوصات دورية',
                subtitle: 'تتبع مواعيد الفحوصات الدورية',
                icon: Icons.calendar_today,
                color: Colors.purple.shade100,
              ),
              const SizedBox(height: 12),
              _buildHorizontalCard(
                context,
                title: 'تقارير طبية',
                subtitle: 'عرض التقارير الطبية الخاصة بك',
                icon: Icons.description,
                color: Colors.teal.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard(BuildContext context, {
    required Color color,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.black87),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Change to start for RTL
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.black87.withAlpha(180)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16), // Use forward arrow for RTL
            ],
          ),
        ),
      ),
    );
  }
}