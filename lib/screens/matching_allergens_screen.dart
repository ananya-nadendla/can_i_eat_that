import 'package:flutter/material.dart';
import 'package:food_allergy_scanner/utils/utils.dart';

class MatchingAllergensScreen extends StatelessWidget {
  final List<String> matchingAllergens; // List of matching allergens
  final List<String> invalidAllergens; // List of invalid allergens
  final List<String> safeIngredients; // List of safe ingredients

  MatchingAllergensScreen({
    required this.matchingAllergens,
    required this.invalidAllergens,
    required this.safeIngredients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (matchingAllergens.isNotEmpty) ...[
                const Center(
                  child: Text(
                    'Unsafe Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: matchingAllergens.map((allergen) {
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(capitalizeFirstLetter(allergen)),
                    );
                  }).toList(),
                ),
              ],
              if (invalidAllergens.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Unrecognized Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: invalidAllergens.map((ingredient) {
                    return ListTile(
                      leading: const Icon(Icons.help,
                          color: Colors.orange), // Blue question mark icon
                      title: Text(capitalizeFirstLetter(ingredient)),
                    );
                  }).toList(),
                ),
              ],
              if (safeIngredients.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Safe Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: safeIngredients.map((ingredient) {
                    return ListTile(
                      leading:
                          const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(capitalizeFirstLetter(ingredient)),
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
}
