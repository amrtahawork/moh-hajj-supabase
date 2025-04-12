import 'package:flutter/material.dart';

class BloodTypeScreen extends StatelessWidget {
  const BloodTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Type'),
      ),
      body: const Center(
        child: Text('Blood Type Screen'),
      ),
    );
  }
}