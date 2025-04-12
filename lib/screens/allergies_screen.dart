import 'package:flutter/material.dart';

class AllergiesScreen extends StatelessWidget {
  const AllergiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allergies'),
      ),
      body: const Center(
        child: Text('Allergies Screen'),
      ),
    );
  }
}