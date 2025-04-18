import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _barcodeController = TextEditingController();
  final String validBarcode = '29410771467915';

  void _validateAndNavigate(String barcode) {
    if (barcode == validBarcode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('باركود خاطي حاول مجددا')));
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
            // Placeholder Icon - Replace 'assets/images/moh_logo.svg' with your correct logo file
            const Icon(
              Icons.local_hospital, // Example placeholder icon
              size: 150,
              color: Colors.blue, // Example color
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: 'أدخل رقم جواز السفر', // Changed to Arabic
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    _validateAndNavigate(_barcodeController.text.trim());
                  },
                ),
              ),
              onSubmitted: (value) {
                _validateAndNavigate(value.trim());
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('مسح الباركود'), // Changed to Arabic
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
      appBar: AppBar(
        title: const Text('مسح الباركود'), // Changed to Arabic
      ),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            Navigator.of(context).pop();
            if (context.mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          }
        },
      ),
    );
  }
}
