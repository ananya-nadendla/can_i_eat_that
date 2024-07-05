import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyProvider extends ChangeNotifier {
  List<String> _allergies = [];
  final List<String> _treeNuts = [
    'Almonds',
    'Brazil Nuts',
    'Cashews',
    'Chestnuts',
    'Hazelnuts',
    'Macadamia Nuts',
    'Pecans',
    'Pine Nuts',
    'Pistachios',
    'Walnuts'
  ];

  List<String> get allergies => _allergies;
  List<String> get treeNuts => _treeNuts;

  AllergyProvider() {
    _loadAllergies();
  }

 void addAllergy(String allergy) {
    if (!_allergies.contains(allergy)) {
      _allergies.add(allergy);
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeAllergy(String allergy) {
    if (_allergies.contains(allergy)) {
      _allergies.remove(allergy);
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeTreeNut(String treeNut) {
    if (_allergies.contains(treeNut)) {
      _allergies.remove(treeNut);
      _saveAllergies();
      notifyListeners();
    }
  }

  void clearAllergies() {
    _allergies.clear();
    _saveAllergies();
    notifyListeners();
  }

  void removeTreeNutsAndCorrespondingNuts() {
    if (_allergies.contains('Tree Nuts')) {
      _allergies.remove('Tree Nuts');
      for (String treeNut in treeNuts) {
        _allergies.remove(treeNut);
      }
      _saveAllergies();
      notifyListeners();
    }
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
