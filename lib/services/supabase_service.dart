import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  // Save other factors data
  Future<bool> saveOtherFactors(List<String> factors, String? details) async {
    try {
      // Get current user ID
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Save to Supabase
      await _client.from('other_factors').upsert({
        'user_id': userId,
        'factors': factors,
        'details': details ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving other factors: $e');
      return false;
    }
  }

  // Save medications
  Future<bool> saveMedication(String medication) async {
    try {
      // Get current user ID
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Save to Supabase
      await _client.from('medications').insert({
        'user_id': userId,
        'medication': medication,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving medication: $e');
      return false;
    }
  }

  // Save comments
  Future<bool> saveComment(String comment) async {
    try {
      // Get current user ID
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Save to Supabase
      await _client.from('comments').upsert({
        'user_id': userId,
        'comment': comment,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving comment: $e');
      return false;
    }
  }

  // Save conditions
  Future<bool> saveConditions(Map<String, dynamic> conditions) async {
    try {
      // Get current user ID
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Save to Supabase
      await _client.from('conditions').upsert({
        'user_id': userId,
        'conditions': conditions,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving conditions: $e');
      return false;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // Get current user ID
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return null;

      // Get user data from different tables
      final otherFactors =
          await _client
              .from('other_factors')
              .select()
              .eq('user_id', userId)
              .single();

      final medications = await _client
          .from('medications')
          .select()
          .eq('user_id', userId);

      final comments =
          await _client
              .from('comments')
              .select()
              .eq('user_id', userId)
              .single();

      final conditions =
          await _client
              .from('conditions')
              .select()
              .eq('user_id', userId)
              .single();

      return {
        'other_factors': otherFactors,
        'medications': medications,
        'comments': comments,
        'conditions': conditions,
      };
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Fetch user by national ID or passport number
  Future<Map<String, dynamic>?> fetchUserByIdOrPassport(String value) async {
    try {
      final response =
          await _client
              .from('user_profile')
              .select()
              .or('national_id.eq.$value,passport_number.eq.$value')
              .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching user by ID or passport: $e');
      return null;
    }
  }
}
