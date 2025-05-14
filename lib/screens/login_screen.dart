import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../main.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;

  Future<void> _validateAndNavigate(String value) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final user = await _supabaseService.fetchUserByIdOrPassport(value);
      if (user != null) {
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
            const Icon(Icons.local_hospital, size: 150, color: Colors.blue),
            const SizedBox(height: 40),
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'أدخل رقم الهوية أو جواز السفر',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            _validateAndNavigate(
                              _barcodeController.text.trim(),
                            );
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
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BarcodeScannerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('مسح الباركود'),
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

class BarcodeScannerScreen extends StatelessWidget {
  const BarcodeScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسح الباركود')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            Navigator.of(context).pop();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (Route<dynamic> route) => false,
              );
            }
          }
        },
      ),
    );
  }
}
