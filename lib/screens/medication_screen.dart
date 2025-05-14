import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  final TextEditingController _controller = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  List<String> _medications = [];

  @override
  void initState() {
    super.initState();
    _fetchMedications();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchMedications() async {
    setState(() {
      _isLoading = true;
    });
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final data = await _supabaseService.client
        .from('medications')
        .select()
        .eq('user_id', userId);
    setState(() {
      _medications =
          data != null
              ? List<String>.from(
                data.map((item) => item['medication'] as String),
              )
              : [];
      _isLoading = false;
    });
  }

  Future<void> _addMedication() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      setState(() => _isLoading = false);
      return;
    }
    final result = await _supabaseService.client.from('medications').insert({
      'user_id': userId,
      'medication': text,
      'created_at': DateTime.now().toIso8601String(),
    });
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الدواء في Supabase')),
      );
      _controller.clear();
      await _fetchMedications();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ الدواء في Supabase')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأدوية')),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'اسم الدواء',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _controller.clear(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addMedication,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'إضافة الدواء',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'الأدوية المضافة:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _medications.isEmpty
                        ? const Center(child: Text('لا توجد أدوية مضافة بعد.'))
                        : ListView.separated(
                          itemCount: _medications.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final med = _medications[index];
                            return ListTile(
                              title: Text(med),
                              leading: const Icon(Icons.medication_outlined),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
