import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
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
                    String displayAllergy = _capitalizeFirstLetter(allergy); // Capitalize first letter for display

                    if (allergy == 'Tree Nuts') {
                      // Display "Tree Nuts" with its corresponding nuts
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(displayAllergy), // Display capitalized allergy name
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
                                      title: Text(_capitalizeFirstLetter(treeNut)), // Display capitalized tree nut
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
                            title: Text(displayAllergy), // Display capitalized allergy name
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
                                      title: Text(_capitalizeFirstLetter(shellfish)), // Display capitalized shellfish
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
                            title: Text(displayAllergy), // Display capitalized allergy name
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
                                      title: Text(_capitalizeFirstLetter(fish)), // Display capitalized fish
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
                            title: Text(displayAllergy), // Display capitalized allergy name
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
                                      title: Text(_capitalizeFirstLetter(legume)), // Display capitalized legume
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
                        title: Text(displayAllergy), // Display capitalized allergy name
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
                                    .map((allergy) => Pluralize().singular(allergy).toLowerCase()) // Compare lowercase singular form to check for duplicates
                                    .contains(Pluralize().singular(newAllergy));
                                if (!isDuplicate) {
                                  allergyProvider.addAllergy(newAllergy); // Add the new allergen
                                  _controller.clear(); // Clear the input field
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('This allergen is already in the list')), // Show duplicate message
                                  );
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
                            onChanged: (String? value) {
                              setState(() {
                                _selectedGroupAllergen = value; // Set selected group allergen
                              });
                            },
                            items: <String>[
                              'Tree Nuts',
                              'Crustacean Shellfish',
                              'Fish',
                              'Legumes',
                            ]
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value), // Display dropdown item
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add), // Add icon button
                          onPressed: () {
                            if (_selectedGroupAllergen != null) { // Check if a group allergen is selected
                              int totalAllergies = allergyProvider.allergies.length; // Total current allergies count
                              if (_selectedGroupAllergen == 'Tree Nuts') {
                                totalAllergies += allergyProvider.treeNuts.length; // Add tree nuts count
                              } else if (_selectedGroupAllergen == 'Crustacean Shellfish') {
                                totalAllergies += allergyProvider.crustaceanShellfish.length; // Add crustacean shellfish count
                              } else if (_selectedGroupAllergen == 'Fish') {
                                totalAllergies += allergyProvider.fish.length; // Add fish count
                              } else if (_selectedGroupAllergen == 'Legumes') {
                                totalAllergies += allergyProvider.legumes.length; // Add legumes count
                              }
                              
                              if (totalAllergies < maxAllergies) { // Check if not exceeding max limit
                                bool isDuplicate = allergyProvider.allergies
                                    .map((allergy) => allergy.toLowerCase())
                                    .contains(_selectedGroupAllergen!.toLowerCase());
                                if (!isDuplicate) {
                                  allergyProvider.addAllergy(_selectedGroupAllergen!); // Add the selected group allergen
                                  if (_selectedGroupAllergen == 'Tree Nuts') { // Check selected group allergen
                                    allergyProvider.treeNuts.forEach((treeNut) { // For each tree nut in the list
                                      if (!allergyProvider.allergies.contains(treeNut)) { // Check if not already in allergies list
                                        allergyProvider.addAllergy(treeNut); // Add tree nut to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Crustacean Shellfish') { // Check selected group allergen
                                    allergyProvider.crustaceanShellfish.forEach((shellfish) { // For each shellfish in the list
                                      if (!allergyProvider.allergies.contains(shellfish)) { // Check if not already in allergies list
                                        allergyProvider.addAllergy(shellfish); // Add shellfish to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Fish') { // Check selected group allergen
                                    allergyProvider.fish.forEach((fish) { // For each fish in the list
                                      if (!allergyProvider.allergies.contains(fish)) { // Check if not already in allergies list
                                        allergyProvider.addAllergy(fish); // Add fish to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Legumes') { // Check selected group allergen
                                    allergyProvider.legumes.forEach((legume) { // For each legume in the list
                                      if (!allergyProvider.allergies.contains(legume)) { // Check if not already in allergies list
                                        allergyProvider.addAllergy(legume); // Add legume to allergies list
                                      }
                                    });
                                  }
                                  setState(() {
                                    _selectedGroupAllergen = null; // Clear selected group allergen
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('This group allergen is already in the list')), // Show duplicate group allergen message
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Adding this group allergen exceeds the maximum limit of 30 allergies')), // Show max allergies message
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

  //For readable formatting on frontend
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text.toLowerCase().split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
