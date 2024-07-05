import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyProvider extends ChangeNotifier {
  List<String> _allergies = [];

  List<String> get allergies => _allergies;

  AllergyProvider() {
    _loadAllergies();
  }

  void addAllergy(String allergy) {
    _allergies.add(allergy);
    notifyListeners();
    _saveAllergies();
  }

  void removeAllergy(String allergy) {
    _allergies.remove(allergy);
    notifyListeners();
    _saveAllergies();
  }

  void clearAllergies() {
    _allergies.clear();
    notifyListeners();
    _saveAllergies();
  }

  Future<void> _saveAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergies', _allergies);
    print('Saved allergies: $_allergies'); // Debugging line
  }

  Future<void> _loadAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _allergies = prefs.getStringList('allergies') ?? [];
    print('Loaded allergies: $_allergies'); // Debugging line
    notifyListeners();
  }
}
