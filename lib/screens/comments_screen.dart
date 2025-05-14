import 'package:flutter/material.dart';
import '../services/health_data_service.dart';
import '../services/supabase_service.dart';

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
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final data =
        await _supabaseService.client
            .from('comments')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
    if (data != null && data['comment'] != null) {
      setState(() {
        _controller.text = data['comment'];
        _currentComment = data['comment'];
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    setState(() {
      _isLoading = true;
    });
    final userId = _supabaseService.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لم يتم العثور على المستخدم')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final text = _controller.text.trim();
    final result = await _supabaseService.client.from('comments').upsert({
      'user_id': userId,
      'comment': text,
      'updated_at': DateTime.now().toIso8601String(),
    });
    setState(() {
      _isLoading = false;
      _currentComment = text;
    });
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعليق في Supabase')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ التعليق في Supabase')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ملاحظات / تعليقات')),
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
