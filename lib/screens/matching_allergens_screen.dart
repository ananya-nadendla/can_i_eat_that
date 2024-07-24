import 'package:flutter/material.dart';

class MatchingAllergensScreen extends StatelessWidget {
  final List<String> matchingAllergens; // List of matching allergens
  final List<String> invalidAllergens; // List of invalid allergens

  MatchingAllergensScreen({
    required this.matchingAllergens,
    required this.invalidAllergens,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Matching Allergens'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchingAllergens.isNotEmpty)
                ...[
                  Center(
                    child: Text(
                      'Matching Allergens:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: matchingAllergens.map((allergen) {
                      return ListTile(
                        leading: Icon(Icons.warning, color: Colors.red),
                        title: Text(_capitalizeFirstLetter(allergen)),
                      );
                    }).toList(),
                  ),
                ],
              if (invalidAllergens.isNotEmpty)
                ...[
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Unrecognized Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 8),
                  Column(
                    children: invalidAllergens.map((ingredient) {
                      return ListTile(
                        leading: Icon(Icons.help, color: Colors.orange), // Blue question mark icon
                        title: Text(_capitalizeFirstLetter(ingredient)),
                      );
                    }).toList(),
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text.toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
