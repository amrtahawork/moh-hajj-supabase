import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';

class SupabaseService {
  bool _isValidUuid(String? uuid) {
    if (uuid == null) return false;
    final RegExp uuidRegExp = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidRegExp.hasMatch(uuid);
  }

  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  // Save other factors data
  Future<bool> saveOtherFactors(
    String userId,
    List<String> factors,
    String? details,
  ) async {
    try {
      if (!_isValidUuid(userId)) {
        print('Error saving other factors: Invalid user ID format.');
        return false;
      }
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
  Future<bool> saveMedication(String userId, String medication) async {
    try {
      if (!_isValidUuid(userId)) {
        print('Error saving medication: Invalid user ID format.');
        return false;
      }
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
  Future<bool> saveComment(String userId, String comment) async {
    try {
      if (!_isValidUuid(userId)) return false;
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
  Future<bool> saveConditions(
    String nationalId,
    Map<String, dynamic> conditions,
  ) async {
    try {
      // Map UI state to DB columns
      final data = {
        'national_id': nationalId,
        'hypertension': conditions['الضغط'] ?? false,
        'diabetes': conditions['السكر'] ?? false,
        'heart_failure': conditions['ضعف عضلة القلب'] ?? false,
        'coronary_artery_disease':
            conditions['امراض الشريان التاجي (ذبحة صدرية جلطة بالقلب)'] ??
            false,
        'liver_fibrosis': conditions['التليف الكبدي'] ?? false,
        'renal_failure': conditions['القصور الكلوي'] ?? false,
        'tumors': conditions['أورام'] ?? false,
        'brain_bleed': conditions['نزيف بالمخ / جلطة بالمخ'] ?? false,
        'hemiplegia': conditions['شلل نصفي / شلل رباعي'] ?? false,
        'neuro_psych': conditions['أمراض عصبية أو نفسية'] ?? false,
        'mouth_bleed': conditions['نزيف من الفم'] ?? false,
        'rectal_bleed': conditions['نزيف من فتحة الشرج'] ?? false,
        'stomach_ulcer': conditions['فرحة بالمعدة أو الإثنا عشر'] ?? false,
        'asthma': conditions['حساسية الصدر (الربو)'] ?? false,
        'tuberculosis': conditions['درن (سل)'] ?? false,
        'lung_fibrosis': conditions['تليف بالرئة'] ?? false,
        'autoimmune': conditions['أمراض مناعية'] ?? false,
        'chronic_blood_disease': conditions['أمراض دم مزمنة'] ?? false,
        'other_conditions': conditions['otherConditionText'] ?? '',
        'updated_at': DateTime.now().toIso8601String(),
      };
      await _client.from('conditions').upsert(data);
      return true;
    } catch (e) {
      print('Error saving conditions: $e');
      return false;
    }
  }

  // Save allergies
  Future<bool> saveAllergies({
    required String userId,
    required bool drugsAllergy,
    required String drugsDetails,
    required bool foodAllergy,
    required String foodDetails,
    required bool otherAllergy,
    required String otherDetails,
    required List<String> selectedAllergies,
  }) async {
    try {
      if (!_isValidUuid(userId)) {
        print('Error saving allergies: Invalid user ID format.');
        return false;
      }
      // Save to Supabase
      await _client.from('allergies').upsert({
        'user_id': userId,
        'drugs_allergy': drugsAllergy,
        'drugs_details': drugsDetails,
        'food_allergy': foodAllergy,
        'food_details': foodDetails,
        'other_allergy': otherAllergy,
        'other_details': otherDetails,
        'selected_allergies': selectedAllergies,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving allergies: $e');
      return false;
    }
  }

  // Save blood type
  Future<bool> saveBloodType({
    required String userId,
    required String bloodType,
    required String rhFactor,
  }) async {
    try {
      if (!_isValidUuid(userId)) {
        print('Error saving blood type: Invalid user ID format.');
        return false;
      }
      // Save to Supabase
      await _client.from('blood_type').upsert({
        'user_id': userId,
        'blood_type': bloodType,
        'rh_factor': rhFactor,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error saving blood type: $e');
      return false;
    }
  }

  // Get blood type
  Future<Map<String, dynamic>?> getBloodType(String userId) async {
    try {
      if (!_isValidUuid(userId)) {
        print('Error getting blood type: Invalid user ID format.');
        return null;
      }
      final response =
          await _client
              .from('blood_type')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting blood type: $e');
      return null;
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String nationalId) async {
    try {
      // Get user data from different tables
      final otherFactors =
          await _client
              .from('other_factors')
              .select()
              .eq('national_id', nationalId)
              .single();

      final medications = await _client
          .from('medications')
          .select()
          .eq('national_id', nationalId);

      final comments =
          await _client
              .from('comments')
              .select()
              .eq('national_id', nationalId)
              .single();

      final conditions =
          await _client
              .from('conditions')
              .select()
              .eq('national_id', nationalId)
              .single();

      final allergies =
          await _client
              .from('allergies')
              .select()
              .eq('national_id', nationalId)
              .maybeSingle();

      return {
        'other_factors': otherFactors,
        'medications': medications,
        'comments': comments,
        'conditions': conditions,
        'allergies': allergies,
      };
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Helper method to authenticate user by ID or passport
  Future<Map<String, dynamic>?> fetchUserByIdOrPassport(
    String identifier,
  ) async {
    try {
      final response =
          await _client
              .from('user_profile')
              .select()
              .or('national_id.eq.$identifier,passport_number.eq.$identifier')
              .maybeSingle();
      return response;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Generic method to fetch user data from any table
  Future<List<Map<String, dynamic>>> fetchUserData(
    String userId,
    String table,
  ) async {
    if (!_isValidUuid(userId)) {
      print('Error fetching $table data: Invalid user ID format.');
      return [];
    }
    try {
      final response = await _client
          .from(table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching $table data: $e');
      return [];
    }
  }

  // Save blood type in user_profile
  Future<bool> saveBloodTypeToProfile({
    required String nationalId,
    required String bloodType,
    required String rhFactor,
  }) async {
    try {
      print(
        'Saving blood type for nationalId: $nationalId, bloodType: $bloodType, rhFactor: $rhFactor',
      );
      final response =
          await _client
              .from('user_profile')
              .update({
                'blood_type': bloodType,
                'rh_factor': rhFactor,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('national_id', nationalId)
              .select();
      print('Update response: $response');
      if (response != null && response is List && response.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error saving blood type to user_profile: $e');
      return false;
    }
  }

  // Fetch blood type from user_profile
  Future<Map<String, dynamic>?> getBloodTypeFromProfile(
    String nationalId,
  ) async {
    try {
      final response =
          await _client
              .from('user_profile')
              .select('blood_type, rh_factor')
              .eq('national_id', nationalId)
              .maybeSingle();
      return response;
    } catch (e) {
      print('Error getting blood type from user_profile: $e');
      return null;
    }
  }
}
