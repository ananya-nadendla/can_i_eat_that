import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AllergyProvider extends ChangeNotifier {
  List<String> _allergies = [];
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


  List<String> get allergies => _allergies;
  List<String> get treeNuts => _treeNuts;
  List<String> get crustaceanShellfish => _crustaceanShellfish;
  List<String> get fish => _fish;
  List<String> get legumes => _legumes;

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

  void removeShellfish(String shellfish) {
    if (_allergies.contains(shellfish)) {
      _allergies.remove(shellfish);
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeFish(String fish) {
    if (_allergies.contains(fish)) {
      _allergies.remove(fish);
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeLegumes(String legume) {
    if (_allergies.contains(legume)) {
      _allergies.remove(legume);
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

  void removeCrustaceanShellfishAndCorrespondingShellfish() {
    if (_allergies.contains('Crustacean Shellfish')) {
      _allergies.remove('Crustacean Shellfish');
      for (String shellfish in crustaceanShellfish) {
        _allergies.remove(shellfish);
      }
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeFishAndCorrespondingFish() {
    if (_allergies.contains('Fish')) {
      _allergies.remove('Fish');
      for (String fish in this.fish) {
        _allergies.remove(fish);
      }
      _saveAllergies();
      notifyListeners();
    }
  }

  void removeLegumesAndCorrespondingLegumes() {
  if (_allergies.contains('Legumes')) {
    _allergies.remove('Legumes');
    for (String legume in legumes) {
      _allergies.remove(legume);
    }
    _saveAllergies();
    notifyListeners();
  }
}


  Future<void> _saveAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('allergies', _allergies);
    print('Saved allergies (${_allergies.length}): $_allergies');  //Debugging line
  }

  Future<void> _loadAllergies() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _allergies = prefs.getStringList('allergies') ?? [];
    print('Loaded allergies (${_allergies.length}): $_allergies'); 
    notifyListeners();
  }
}
