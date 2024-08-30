import 'package:flutter/material.dart';
import 'package:food_allergy_scanner/utils/utils.dart';

class MatchingAllergensScreen extends StatelessWidget {
  final List<String> matchingAllergens; // List of matching allergens
  final List<String> invalidIngredients; // List of invalid allergens
  final List<String> safeIngredients; // List of safe ingredients

  MatchingAllergensScreen({
    required this.matchingAllergens, //Stores ingredients that match user's allergens
    required this.invalidIngredients, //Store ingredients that dictionary doesn't recognize
    required this.safeIngredients, //Store non-allergen ingredients
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'), // Title for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          // Scroll view to allow scrolling when content is long
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the start (left)
            children: [
              // Display Matching Allergens
              if (matchingAllergens.isNotEmpty) ...[
                const Center(
                  child: Text(
                    'Unsafe Ingredients:', //Section title
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8), // Spacer for visual separation
                Column(
                  // List of matching allergens with warning icons
                  children: matchingAllergens.map((allergen) {
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(capitalizeFirstLetter(allergen)),
                    );
                  }).toList(),
                ),
              ],
              //Display Unrecognized (invalid) Ingredients
              if (invalidIngredients.isNotEmpty) ...[
                const SizedBox(
                    height: 20), // Spacer for separation between sections
                const Center(
                  child: Text(
                    'Unrecognized Ingredients:', //Section title
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8), // Spacer for visual separation
                Column(
                  // List of unrecognized ingredients with question icons
                  children: invalidIngredients.map((ingredient) {
                    return ListTile(
                      leading: const Icon(Icons.help,
                          color: Colors.orange), // Blue question mark icon
                      title: Text(capitalizeFirstLetter(ingredient)),
                    );
                  }).toList(),
                ),
              ],
              //Display Safe Ingredients
              if (safeIngredients.isNotEmpty) ...[
                const SizedBox(
                    height: 20), // Spacer for separation between sections
                const Center(
                  child: Text(
                    'Safe Ingredients:', //Section title
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 8), // Spacer for visual separation
                Column(
                  // List of safe ingredients with check icons
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
