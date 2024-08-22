import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyProvider extends ChangeNotifier {
  // List to store user-selected allergies
  List<String> _allergies = [];

  // Predefined valid words for allergy checking
  final List<String> predefinedValidWords = ['vit', 'fd&c', 'd&c'];

  // Lists of allergens by type
  final List<String> _treeNuts = [
    'Almond',
    'Brazil Nut',
    'Cashew',
    'Chestnut',
    'Hazelnut',
    'Macadamia Nut',
    'Pecan',
    'Pine Nut',
    'Pistachio',
    'Walnut'
  ];
  final List<String> _crustaceanShellfish = [
    'Crab',
    'Crayfish',
    'Lobster',
    'Shrimp',
    'Prawn'
  ];
  final List<String> _fish = [
    'Anchovy',
    'Bass',
    'Catfish',
    'Cod',
    'Flounder',
    'Grouper',
    'Haddock',
    'Hake',
    'Halibut',
    'Herring',
    'Mahi Mahi',
    'Perch',
    'Pike',
    'Pollock',
    'Salmon',
    'Scrod',
    'Sole',
    'Snapper',
    'Swordfish',
    'Tilapia',
    'Trout',
    'Tuna'
  ];
  final List<String> _legumes = [
    'Peanut',
    'Chickpea',
    'Lentil',
    'Lupin',
    'Pea',
    'Soybeans'
  ];

  // Getters for the allergen lists
  List<String> get allergies => _allergies;
  List<String> get treeNuts => _treeNuts;
  List<String> get crustaceanShellfish => _crustaceanShellfish;
  List<String> get fish => _fish;
  List<String> get legumes => _legumes;

  // Constructor that loads saved allergies from SharedPreferences
  AllergyProvider() {
    _loadAllergies();
  }

  // Add allergy to the list (if it's not already present)
  void addAllergy(String allergy) {
    if (!_allergies.contains(allergy)) {
      _allergies.add(allergy);
      _saveAllergies();
      notifyListeners();
    }
  }

  // Remove allergy from the list (if it exists)
  void removeAllergy(String allergy) {
    if (_allergies.contains(allergy)) {
      _allergies.remove(allergy);
      _saveAllergies();
      notifyListeners();
    }
  }

  // Clear all allergies from list
  void clearAllergies() {
    _allergies.clear();
    _saveAllergies();
    notifyListeners();
  }

  // Remove group allergy and its related allergens from the list
  void removeAllergensOfType(String type, List<String> allergens) {
    if (_allergies.contains(type)) {
      _allergies.remove(type);
      for (String allergen in allergens) {
        _allergies.remove(allergen);
      }
      _saveAllergies();
      notifyListeners();
    }
  }

  // Convenience methods to remove allergens by type
  void removeTreeNuts() => removeAllergensOfType('Tree Nuts', treeNuts);
  void removeCrustaceanShellfish() => removeAllergensOfType('Crustacean Shellfish', crustaceanShellfish);
  void removeFish() => removeAllergensOfType('Fish', fish);
  void removeLegumes() => removeAllergensOfType('Legumes', legumes);

  // Saves the current list of allergies to SharedPreferences
  Future<void> _saveAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergies', _allergies);
    print('Saved allergies (${_allergies.length}): $_allergies'); // Debugging line
  }

  // Loads the list of allergies from SharedPreferences
  Future<void> _loadAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _allergies = prefs.getStringList('allergies') ?? [];
    print('Loaded allergies (${_allergies.length}): $_allergies');
    notifyListeners();
  }
}
