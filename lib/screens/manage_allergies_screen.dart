import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';

class ManageAllergiesScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  static const int maxAllergies = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Allergies'), // Title for the app bar
      ),
      body: Consumer<AllergyProvider>( // Consumer to listen to changes in AllergyProvider
        builder: (context, allergyProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: allergyProvider.allergies.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    String allergy = allergyProvider.allergies[index]; // Get each allergy from the list
                    return ListTile(
                      title: Text(allergy), // Display the allergy name
                      trailing: IconButton(
                        icon: Icon(Icons.delete), // Delete icon button
                        onPressed: () => allergyProvider.removeAllergy(allergy), // Remove allergy when pressed
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Padding around the input row
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller, // Controller for text input
                        decoration: InputDecoration(labelText: 'Add Allergy'), // Input field label
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add), // Add icon button
                      onPressed: () {
                        String newAllergy = _controller.text.trim().toLowerCase(); // Normalize input to lowercase
                        if (newAllergy.isNotEmpty) { // Check if input is not empty
                          if (allergyProvider.allergies.length < maxAllergies) { // Check if not exceeding max limit
                            bool isDuplicate = allergyProvider.allergies
                                .map((allergy) => allergy.toLowerCase()) // Compare lowercase to check for duplicates
                                .contains(newAllergy);
                            if (!isDuplicate) { // If not a duplicate, add the allergy
                              allergyProvider.addAllergy(_controller.text.trim());
                              _controller.clear(); // Clear the input field
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('This allergen is already in the list')), // Show duplicate message
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('You can add a maximum of 20 allergies')), // Show max allergies message
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please enter a valid allergen')), // Show empty input message
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
