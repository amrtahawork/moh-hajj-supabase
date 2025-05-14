import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';

class HealthDataService {
  // Singleton pattern
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

  // Supabase service
  final SupabaseService _supabaseService = SupabaseService();

  // Local storage keys
  static const String _medicationsKey = 'medications';
  static const String _commentsKey = 'comments';
  static const String _otherFactorsKey = 'otherFactors';
  static const String _conditionsKey = 'conditions';

  // In-memory cache
  List<String> _medications = [];
  String _comments = '';
  List<String> _otherFactors = [];
  Map<String, dynamic> _conditions = {};

  // Getters
  List<String> get medications => _medications;
  String get comments => _comments;
  List<String> get otherFactors => _otherFactors;
  Map<String, dynamic> get conditions => _conditions;

  // Initialize data from Supabase and fallback to local storage
  Future<void> init() async {
    // Try to load from Supabase first
    final userData = await _supabaseService.getUserData();
    
    if (userData != null) {
      // Process medications
      if (userData['medications'] != null) {
        _medications = (userData['medications'] as List)
            .map((item) => item['medication'] as String)
            .toList();
      }
      
      // Process comments
      if (userData['comments'] != null && userData['comments']['comment'] != null) {
        _comments = userData['comments']['comment'] as String;
      }
      
      // Process other factors
      if (userData['other_factors'] != null && userData['other_factors']['factors'] != null) {
        _otherFactors = List<String>.from(userData['other_factors']['factors']);
      }
      
      // Process conditions
      if (userData['conditions'] != null && userData['conditions']['conditions'] != null) {
        _conditions = userData['conditions']['conditions'] as Map<String, dynamic>;
      }
      
      // Save to local storage for offline access
      _saveToLocalStorage();
    } else {
      // Fallback to local storage if Supabase data is not available
      final prefs = await SharedPreferences.getInstance();
      
      // Load medications
      final medicationsJson = prefs.getStringList(_medicationsKey) ?? [];
      _medications = medicationsJson;
      
      // Load comments
      _comments = prefs.getString(_commentsKey) ?? '';
      
      // Load other factors
      final otherFactorsJson = prefs.getStringList(_otherFactorsKey) ?? [];
      _otherFactors = otherFactorsJson;
      
      // Load conditions
      final conditionsJson = prefs.getString(_conditionsKey);
      if (conditionsJson != null) {
        _conditions = json.decode(conditionsJson);
      }
    }
  }

  // Add medication
  Future<bool> addMedication(String medication) async {
    _medications.add(medication);
    await _saveMedications();
    return await saveUserData('medications', {'medication': medication});
  }

  // Remove medication
  Future<bool> removeMedication(String medication) async {
    _medications.remove(medication);
    await _saveMedications();
    // Note: This is a simplified approach. In a real app, you would need to
    // implement a proper delete operation in the Supabase service
    return true;
  }

  // Save medications to local storage
  Future<void> _saveMedications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_medicationsKey, _medications);
  }

  // Update comments
  Future<bool> updateComments(String comments) async {
    _comments = comments;
    await _saveComments();
    return await saveUserData('comments', {'comment': comments});
  }

  // Save comments to local storage
  Future<void> _saveComments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_commentsKey, _comments);
  }

  // Add other factor
  Future<bool> addOtherFactor(String factor) async {
    _otherFactors.add(factor);
    await _saveOtherFactors();
    return await saveUserData('other-factors', {'factors': _otherFactors, 'details': ''});
  }

  // Remove other factor
  Future<bool> removeOtherFactor(String factor) async {
    _otherFactors.remove(factor);
    await _saveOtherFactors();
    return await saveUserData('other-factors', {'factors': _otherFactors, 'details': ''});
  }

  // Save other factors to local storage
  Future<void> _saveOtherFactors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_otherFactorsKey, _otherFactors);
  }

  // Update conditions
  Future<bool> updateConditions(Map<String, dynamic> conditions) async {
    _conditions = conditions;
    await _saveConditions();
    return await saveUserData('conditions', conditions);
  }

  // Save conditions to local storage
  Future<void> _saveConditions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_conditionsKey, json.encode(_conditions));
  }

  // Save all data to local storage
  Future<void> _saveToLocalStorage() async {
    await _saveMedications();
    await _saveComments();
    await _saveOtherFactors();
    await _saveConditions();
  }

  // Save user data to Supabase
  Future<bool> saveUserData(String dataType, Map<String, dynamic> data) async {
    try {
      // Determine which Supabase method to call based on the data type
      bool supabaseSuccess = false;
      
      if (dataType == 'other-factors') {
        final factors = data['factors'] as List<String>;
        final details = data['details'] as String?;
        supabaseSuccess = await _supabaseService.saveOtherFactors(factors, details);
      } else if (dataType == 'medications') {
        final medication = data['medication'] as String;
        supabaseSuccess = await _supabaseService.saveMedication(medication);
      } else if (dataType == 'comments') {
        final comment = data['comment'] as String;
        supabaseSuccess = await _supabaseService.saveComment(comment);
      } else if (dataType == 'conditions') {
        supabaseSuccess = await _supabaseService.saveConditions(data);
      }
      
      return supabaseSuccess;
    } catch (e) {
      print('Error saving data to Supabase: $e');
      return false;
    }
  }
}