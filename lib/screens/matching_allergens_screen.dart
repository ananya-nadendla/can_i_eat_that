import 'package:flutter/material.dart';

class MatchingAllergensScreen extends StatelessWidget {
  final List<String> matchingAllergens; // List of matching allergens received as input

  MatchingAllergensScreen({required this.matchingAllergens}); // Constructor to initialize with matching allergens

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Allergens'), // AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding around the SingleChildScrollView
        child: SingleChildScrollView( // Widget to make the content scrollable
          child: Column( // Column to vertically align list of matching allergens
            children: matchingAllergens.map((allergen) {
              return ListTile( // ListTile for each matching allergen
                leading: Icon(Icons.warning, color: Colors.red), // Red warning icon before the allergen
                title: Text(_capitalizeFirstLetter(allergen)), // Display the name of the allergen
              );
            }).toList(), // Convert the mapped list into a list of widgets
          ),
        ),
      ),
    );
  }
}


//For readable formatting on frontend
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text.toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
