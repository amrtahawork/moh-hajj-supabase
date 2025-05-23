import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

// Add a simple static holder for the current user ID and profile
class AppUser {
  static String? currentUserId;
  static Map<String, dynamic>? profile;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final TextEditingController _barcodeController = TextEditingController(); // Remove controller
  bool _isLoading = false;
  String _loginValue = '';

  Future<void> _validateAndNavigate(String identifier) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response =
          await Supabase.instance.client
              .from('user_profile')
              .select()
              .or('national_id.eq.$identifier,passport_number.eq.$identifier')
              .maybeSingle();

      if (response != null) {
        // Debug print the full response
        print('Supabase user_profile response: $response');
        // Store the authenticated user's information
        AppUser.currentUserId = response['national_id'];
        AppUser.profile = response;
        print(
          'Logged in userId (should be UUID): \\${AppUser.currentUserId}',
        ); // Debug print

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على مستخدم بهذا الرقم أو جواز السفر'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في الاتصال بالخادم: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دخول'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/moh_egy.png', width: 150, height: 150),
            const SizedBox(height: 40),
            TextField(
              // controller: _barcodeController, // Remove controller
              onChanged: (value) {
                _loginValue = value;
              },
              decoration: InputDecoration(
                labelText: 'أدخل رقم البطاقة الشخصية',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            _validateAndNavigate(_loginValue.trim());
                          },
                ),
              ),
              onSubmitted: (value) {
                if (!_isLoading) {
                  _validateAndNavigate(value.trim());
                }
              },
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              ElevatedButton.icon(
                onPressed:
                    _isLoading
                        ? null
                        : () {
                          FocusScope.of(context).unfocus();
                          _validateAndNavigate(_loginValue.trim());
                        },
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// class BarcodeScannerScreen extends StatelessWidget {
//   const BarcodeScannerScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('مسح الباركود')),
//       body: MobileScanner(
//         onDetect: (capture) async {
//           if (capture.barcodes.isNotEmpty) {
//             final String scannedCode = capture.barcodes.first.rawValue ?? '';
//             Navigator.of(context).pop();
//             if (context.mounted) {
//               final loginScreen =
//                   context.findAncestorStateOfType<_LoginScreenState>();
//               if (loginScreen != null) {
//                 await loginScreen._validateAndNavigate(scannedCode);
//               }
//             }
//           }
//         },
//       ),
//     );
//   }
// }
