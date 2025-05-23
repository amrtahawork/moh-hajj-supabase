import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser

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

    String? nationalId = AppUser.currentUserId;
    if (nationalId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await _supabaseService.client
              .from('medications')
              .select('medication')
              .eq('national_id', nationalId)
              .maybeSingle();

      if (data != null &&
          data['medication'] != null &&
          data['medication'].toString().isNotEmpty) {
        setState(() {
          _medications =
              data['medication']
                  .toString()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
        });
      } else {
        setState(() {
          _medications = [];
        });
      }
    } catch (e) {
      setState(() {
        _medications = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addMedication() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    if (nationalId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await _supabaseService.client
              .from('medications')
              .select('medication')
              .eq('national_id', nationalId)
              .maybeSingle();

      String newMed = _controller.text.trim();
      List<String> meds = [];
      if (data != null &&
          data['medication'] != null &&
          data['medication'].toString().isNotEmpty) {
        meds =
            data['medication']
                .toString()
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
      }
      meds.add(newMed);

      String updatedMedications = meds.join(',');

      await _supabaseService.client.from('medications').upsert({
        'national_id': nationalId,
        'medication': updatedMedications,
      });

      setState(() {
        _medications = meds;
        _controller.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إضافة الدواء')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedication(String medication) async {
    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    if (nationalId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await _supabaseService.client
              .from('medications')
              .select('medication')
              .eq('national_id', nationalId)
              .maybeSingle();

      List<String> meds = [];
      if (data != null &&
          data['medication'] != null &&
          data['medication'].toString().isNotEmpty) {
        meds =
            data['medication']
                .toString()
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
      }
      meds.remove(medication);

      String updatedMedications = meds.join(',');

      await _supabaseService.client.from('medications').upsert({
        'national_id': nationalId,
        'medication': updatedMedications,
      });

      setState(() {
        _medications = meds;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حذف الدواء')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأدوية'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 36),
          onPressed: () => Navigator.of(context).maybePop(),
          color: Theme.of(context).colorScheme.onPrimary,
          tooltip: 'رجوع',
        ),
      ),
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
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () => _deleteMedication(med),
                              ),
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
