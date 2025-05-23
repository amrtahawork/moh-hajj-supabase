import 'package:flutter/material.dart';
import '../services/health_data_service.dart';
import '../services/supabase_service.dart';
import '../screens/login_screen.dart'; // Import for AppUser

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _controller = TextEditingController();
  final HealthDataService _service = HealthDataService();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  String _currentComment = '';

  @override
  void initState() {
    super.initState();
    _fetchComment();
  }

  Future<void> _fetchComment() async {
    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for comment: $nationalId');
    if (nationalId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
        );
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data =
          await _supabaseService.client
              .from('comments')
              .select()
              .eq('national_id', nationalId)
              .maybeSingle();

      if (data != null && data['comment'] != null) {
        setState(() {
          _controller.text = data['comment'];
          _currentComment = data['comment'];
        });
      }
    } catch (e) {
      print('Error fetching comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    if (_controller.text == _currentComment) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? nationalId = AppUser.currentUserId;
    print('Using nationalId for comment save: $nationalId');
    if (nationalId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً')),
        );
      });
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await _supabaseService.client.from('comments').upsert({
        'national_id': nationalId,
        'comment': _controller.text,
        'updated_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم حفظ الملاحظات')));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving comment: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ الملاحظات: $e')));
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
        title: const Text('الملاحظات'),
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
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'أضف ملاحظة أو تعليق',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveComment,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(height: 32),
              if (_currentComment.isNotEmpty)
                Text(
                  'التعليق الحالي:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              if (_currentComment.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_currentComment),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
