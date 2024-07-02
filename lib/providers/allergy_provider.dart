import 'package:flutter/material.dart';

class AllergyProvider extends ChangeNotifier {
  List<String> _allergies = [];

  List<String> get allergies => _allergies;

  void addAllergy(String allergy) {
    _allergies.add(allergy);
    notifyListeners();
  }

  void removeAllergy(String allergy) {
    _allergies.remove(allergy);
    notifyListeners();
  }

  void clearAllergies() {
    _allergies.clear();
    notifyListeners();
  }
}
