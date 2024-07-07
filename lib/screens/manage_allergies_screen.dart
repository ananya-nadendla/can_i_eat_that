import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';

class ManageAllergiesScreen extends StatefulWidget {
  @override
  _ManageAllergiesScreenState createState() => _ManageAllergiesScreenState();
}

class _ManageAllergiesScreenState extends State<ManageAllergiesScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int maxAllergies = 20;
  String? _selectedGroupAllergen;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Allergies'), // Title for the app bar
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep), // Icon for the "Clear All" button
            onPressed: () {
              // Show a confirmation dialog before clearing all allergies
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Clear All Allergies'),
                  content: Text('Are you sure you want to clear all allergies?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), // Cancel button
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AllergyProvider>(context, listen: false).clearAllergies(); // Clear all allergies
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Clear All Allergies', // Tooltip text
          ),
        ],
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
                    if (allergy == 'Tree Nuts') {
                      // Display "Tree Nuts" with its corresponding nuts
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('Tree Nuts'), // Display "Tree Nuts"
                            trailing: IconButton(
                              icon: Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider.removeTreeNutsAndCorrespondingNuts(), // Remove "Tree Nuts" and corresponding nuts
                            ),
                          ),
                          ...allergyProvider.treeNuts.map((treeNut) {
                            return allergyProvider.allergies.contains(treeNut)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: ListTile(
                                      title: Text(treeNut), // Display each tree nut
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeTreeNut(treeNut), // Remove specific tree nut
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    } else if (allergyProvider.treeNuts.contains(allergy)) {
                      // Skip rendering individual tree nuts as they are handled above
                      return Container();
                    } else {
                      // Display other allergens
                      return ListTile(
                        title: Text(allergy), // Display the allergy name
                        trailing: IconButton(
                          icon: Icon(Icons.delete), // Delete icon button
                          onPressed: () => allergyProvider.removeAllergy(allergy), // Remove allergy when pressed
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Padding around the input row
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller, // Controller for text input
                            decoration: InputDecoration(
                              labelText: 'Add Allergy', // Input field label
                            ),
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
                                if (isDuplicate) { // Check for duplicates
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('This allergen is already in the list')), // Show duplicate message
                                  );
                                } else {
                                  allergyProvider.addAllergy(_controller.text.trim()); // Add the allergy
                                  _controller.clear(); // Clear the input field
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
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            hint: Text('Select Group Allergen'), // Dropdown hint text
                            value: _selectedGroupAllergen, // Selected group allergen value
                            onChanged: (String? newValue) { // Dropdown value change handler
                              setState(() {
                                _selectedGroupAllergen = newValue; // Update selected group allergen
                              });
                            },
                            items: <String>['Tree Nuts'] // Dropdown items
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value), // Display dropdown item text
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add), // Add icon button
                          onPressed: () {
                            if (_selectedGroupAllergen != null) { // Check if a group allergen is selected
                              if (allergyProvider.allergies.length < maxAllergies) { // Check if not exceeding max limit
                                bool isDuplicate = allergyProvider.allergies
                                    .map((allergy) => allergy.toLowerCase()) // Compare lowercase to check for duplicates
                                    .contains('tree nuts');
                                if (!isDuplicate) { // Check for duplicates
                                  allergyProvider.addAllergy('Tree Nuts'); // Add "Tree Nuts"
                                  allergyProvider.treeNuts.forEach((treeNut) {
                                    if (!allergyProvider.allergies.contains(treeNut)) {
                                      allergyProvider.addAllergy(treeNut); // Add corresponding nuts
                                    }
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tree Nuts are already in the list')), // Show duplicate message
                                  );
                                }
                                setState(() {
                                  _selectedGroupAllergen = null; // Reset selected group allergen
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('You can add a maximum of 20 allergies')), // Show max allergies message
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select a group allergen')), // Show empty group allergen message
                              );
                            }
                          },
                        ),
                      ],
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
