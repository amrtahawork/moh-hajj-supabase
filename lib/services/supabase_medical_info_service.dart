import 'supabase_service.dart';


class MedicalInfo {
  final List<String> medications;
  final String comments;
  final Map<String, dynamic> allergies;
  final Map<String, dynamic> conditionsMap;
  final List<String> selectedConditions;
  final Map<String, dynamic> otherFactorsMap;
  final List<String> selectedOtherFactors;

  MedicalInfo({
    required this.medications,
    required this.comments,
    required this.allergies,
    required this.conditionsMap,
    required this.selectedConditions,
    required this.otherFactorsMap,
    required this.selectedOtherFactors,
  });
}

class SupabaseMedicalInfoService {
  final SupabaseService _supabaseService = SupabaseService();

  Future<MedicalInfo?> fetchMedicalInfo(String nationalId) async {
    final userData = await _supabaseService.getUserData(nationalId);
    if (userData == null) return null;

    // Medications
    List<String> medications = [];
    if (userData['medications'] != null) {
      medications =
          (userData['medications'] as List)
              .map((item) => item['medication'] as String)
              .where((m) => m != null && m.isNotEmpty)
              .toList();
    }

    // Comments
    String comments = '';
    if (userData['comments'] != null &&
        userData['comments']['comment'] != null) {
      comments = userData['comments']['comment'] as String;
    }

    // Allergies (new structure)
    Map<String, dynamic> allergies = {};
    if (userData['allergies'] != null) {
      final a = userData['allergies'];
      allergies = {
        'drugs_allergy': a['drugs_allergy'] ?? false,
        'drugs_details': a['drugs_details'] ?? '',
        'food_allergy': a['food_allergy'] ?? false,
        'food_details': a['food_details'] ?? '',
        'other_allergy': a['other_allergy'] ?? false,
        'other_details': a['other_details'] ?? '',
      };
    }

    // Conditions
    Map<String, dynamic> conditionsMap = {};
    List<String> selectedConditions = [];
    if (userData['conditions'] != null) {
      final c = userData['conditions'];
      conditionsMap = Map<String, dynamic>.from(c);
      final conditionLabels = {
        'الضغط': c['hypertension'],
        'السكر': c['diabetes'],
        'ضعف عضلة القلب': c['heart_failure'],
        'امراض الشريان التاجي (ذبحة صدرية جلطة بالقلب)':
            c['coronary_artery_disease'],
        'التليف الكبدي': c['liver_fibrosis'],
        'القصور الكلوي': c['renal_failure'],
        'أورام': c['tumors'],
        'نزيف بالمخ / جلطة بالمخ': c['brain_bleed'],
        'شلل نصفي / شلل رباعي': c['hemiplegia'],
        'أمراض عصبية أو نفسية': c['neuro_psych'],
        'نزيف من الفم': c['mouth_bleed'],
        'نزيف من فتحة الشرج': c['rectal_bleed'],
        'فرحة بالمعدة أو الإثنا عشر': c['stomach_ulcer'],
        'حساسية الصدر (الربو)': c['asthma'],
        'درن (سل)': c['tuberculosis'],
        'تليف بالرئة': c['lung_fibrosis'],
        'أمراض مناعية': c['autoimmune'],
        'أمراض دم مزمنة': c['chronic_blood_disease'],
      };
      selectedConditions =
          conditionLabels.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .toList();
      if (c['other_conditions'] != null &&
          c['other_conditions'].toString().isNotEmpty) {
        selectedConditions.add('أخرى: ${c['other_conditions']}');
      }
    }

    // Other Factors
    Map<String, dynamic> otherFactorsMap = {};
    List<String> selectedOtherFactors = [];
    if (userData['other_factors'] != null) {
      final f = userData['other_factors'];
      otherFactorsMap = Map<String, dynamic>.from(f);
      final factorLabels = {
        'تم حجزك في مستشفى': f['hospitalized'],
        'تم حجزك في رعاية مركزة': f['icu'],
        'أجريت لك عملية جراحية': f['surgery'],
        'أجريت لك قسطرة قلبية أو محية': f['cardiac_catheterization'],
        'أجريت لك جلسات غسيل كلوي': f['dialysis'],
        'أجريت لك جلسات علاج كيماوي/إشعاعي': f['chemo_radiation'],
        'أجري لك منظار جهاز هضمي': f['gi_endoscopy'],
        'أجري لك منظار آخر (أذكر نوعه)': f['other_endoscopy'],
        'تمت لك إجراءات أخرى (أذكرها)': f['other_procedure'],
      };
      selectedOtherFactors =
          factorLabels.entries
              .where((e) => e.value == true)
              .map((e) => e.key)
              .toList();
      if (f['other_endoscopy_details'] != null &&
          f['other_endoscopy_details'].toString().isNotEmpty) {
        selectedOtherFactors.add(
          'تفاصيل منظار آخر: ${f['other_endoscopy_details']}',
        );
      }
      if (f['other_procedure_details'] != null &&
          f['other_procedure_details'].toString().isNotEmpty) {
        selectedOtherFactors.add(
          'تفاصيل إجراء آخر: ${f['other_procedure_details']}',
        );
      }
    }

    return MedicalInfo(
      medications: medications,
      comments: comments,
      allergies: allergies,
      conditionsMap: conditionsMap,
      selectedConditions: selectedConditions,
      otherFactorsMap: otherFactorsMap,
      selectedOtherFactors: selectedOtherFactors,
    );
  }
}
