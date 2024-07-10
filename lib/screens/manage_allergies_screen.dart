import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';

class ManageAllergiesScreen extends StatefulWidget {
  @override
  _ManageAllergiesScreenState createState() => _ManageAllergiesScreenState();
}

class _ManageAllergiesScreenState extends State<ManageAllergiesScreen> {
  final TextEditingController _controller = TextEditingController();
  static const int maxAllergies = 30;
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
                    } else if (allergy == 'Crustacean Shellfish') {
                      // Display "Crustacean Shellfish" with its corresponding shellfish
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('Crustacean Shellfish'), // Display "Crustacean Shellfish"
                            trailing: IconButton(
                              icon: Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider.removeCrustaceanShellfishAndCorrespondingShellfish(), // Remove "Crustacean Shellfish" and corresponding shellfish
                            ),
                          ),
                          ...allergyProvider.crustaceanShellfish.map((shellfish) {
                            return allergyProvider.allergies.contains(shellfish)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: ListTile(
                                      title: Text(shellfish), // Display each shellfish
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeShellfish(shellfish), // Remove specific shellfish
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    } else if (allergy == 'Fish') {
                      // Display "Fish" with its corresponding fish
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('Fish'), // Display "Fish"
                            trailing: IconButton(
                              icon: Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider.removeFishAndCorrespondingFish(), // Remove "Fish" and corresponding fish
                            ),
                          ),
                          ...allergyProvider.fish.map((fish) {
                            return allergyProvider.allergies.contains(fish)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: ListTile(
                                      title: Text(fish), // Display each fish
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeFish(fish), // Remove specific fish
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    } else if (allergy == 'Legumes') {
                      // Display "Legumes" with its corresponding legumes
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text('Legumes'), // Display "Legumes"
                            trailing: IconButton(
                              icon: Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider.removeLegumesAndCorrespondingLegumes(), // Remove "Legumes" and corresponding legumes
                            ),
                          ),
                          ...allergyProvider.legumes.map((legume) {
                            return allergyProvider.allergies.contains(legume)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: ListTile(
                                      title: Text(legume), // Display each legume
                                      trailing: IconButton(
                                        icon: Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeAllergy(legume), // Remove specific legume
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    } else if (allergyProvider.treeNuts.contains(allergy) ||
                               allergyProvider.crustaceanShellfish.contains(allergy) ||
                               allergyProvider.fish.contains(allergy) ||
                               allergyProvider.legumes.contains(allergy)) {
                      // Skip rendering individual items handled above
                      return Container();
                    } else {
                      // Display other individual allergens
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
                              labelText: 'Input Single Allergen', // Input field label
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
                                  allergyProvider.addAllergy(newAllergy); // Add the new allergen
                                  _controller.clear(); // Clear the input field
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('You can add a maximum of 30 allergies')), // Show max allergies message
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
                            items: <String>['Tree Nuts', 'Crustacean Shellfish', 'Fish', 'Legumes'] // Dropdown items
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
                              // Calculate the total allergies if we add the selected group
                              int totalAllergies = allergyProvider.allergies.length;
                              if (_selectedGroupAllergen == 'Tree Nuts') {
                                totalAllergies += allergyProvider.treeNuts.length;
                              } else if (_selectedGroupAllergen == 'Crustacean Shellfish') {
                                totalAllergies += allergyProvider.crustaceanShellfish.length;
                              } else if (_selectedGroupAllergen == 'Fish') {
                                totalAllergies += allergyProvider.fish.length;
                              } else if (_selectedGroupAllergen == 'Legumes') {
                                totalAllergies += allergyProvider.legumes.length;
                              }
                              // Check if adding the selected group allergen exceeds the max limit
                              if (totalAllergies < maxAllergies) {
                                // Proceed with adding the group allergen and corresponding allergens
                                bool isDuplicate = allergyProvider.allergies
                                    .map((allergy) => allergy.toLowerCase())
                                    .contains(_selectedGroupAllergen!.toLowerCase());
                                if (!isDuplicate) {
                                  allergyProvider.addAllergy(_selectedGroupAllergen!);
                                  if (_selectedGroupAllergen == 'Tree Nuts') {
                                    allergyProvider.treeNuts.forEach((treeNut) {
                                      if (!allergyProvider.allergies.contains(treeNut)) {
                                        allergyProvider.addAllergy(treeNut);
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Crustacean Shellfish') {
                                    allergyProvider.crustaceanShellfish.forEach((shellfish) {
                                      if (!allergyProvider.allergies.contains(shellfish)) {
                                        allergyProvider.addAllergy(shellfish);
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Fish') {
                                    allergyProvider.fish.forEach((fish) {
                                      if (!allergyProvider.allergies.contains(fish)) {
                                        allergyProvider.addAllergy(fish);
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Legumes') {
                                    allergyProvider.legumes.forEach((legume) {
                                      if (!allergyProvider.allergies.contains(legume)) {
                                        allergyProvider.addAllergy(legume);
                                      }
                                    });
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('This group allergen is already in the list')),
                                  );
                                }
                                setState(() {
                                  _selectedGroupAllergen = null;
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Adding this group allergen exceeds the maximum limit of 30 allergies')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please select a group allergen')),
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
