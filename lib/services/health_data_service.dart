import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_screen.dart'; // For AppUser

class HealthDataService {
  // Singleton pattern
  static final HealthDataService _instance = HealthDataService._internal();
  factory HealthDataService() => _instance;
  HealthDataService._internal();

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
  List<String> _apiConditions = [];
  List<String> _apiOtherFactors = [];

  // Getters
  List<String> get medications => _medications;
  String get comments => _comments;
  List<String> get otherFactors => _otherFactors;
  Map<String, dynamic> get conditions => _conditions;
  List<String> get apiConditions => _apiConditions;
  List<String> get apiOtherFactors => _apiOtherFactors;

  // Initialize data from Supabase and fallback to local storage
  Future<void> init() async {
    // Remove all Supabase data extraction logic from this file. The new service will handle it.
  }

  // Add medication
  Future<bool> addMedication(String medication) async {
    _medications.add(medication);
    await _saveMedications();
    return true;
  }

  // Remove medication
  Future<bool> removeMedication(String medication) async {
    _medications.remove(medication);
    await _saveMedications();
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
    return true;
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
    return true;
  }

  // Remove other factor
  Future<bool> removeOtherFactor(String factor) async {
    _otherFactors.remove(factor);
    await _saveOtherFactors();
    return true;
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
    return true;
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
}
