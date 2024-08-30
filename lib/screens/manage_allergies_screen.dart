import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/utils/utils.dart';

class ManageAllergiesScreen extends StatefulWidget {
  @override
  _ManageAllergiesScreenState createState() => _ManageAllergiesScreenState();
}

class _ManageAllergiesScreenState extends State<ManageAllergiesScreen> {
  // Text controller to manage input for adding allergens
  final TextEditingController _controller = TextEditingController();
  static const int maxAllergies = 30; // Max limit for number of allergies that can be added
  String? _selectedGroupAllergen; // Stores the currently selected group allergen from dropdown

  @override
  void initState() {
    super.initState();
    // Listener to update state whenever text input changes
    _controller.addListener(() {
      setState(() {});
    });
  }

  // Dispose of the controller to free up resources
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Allergies'),  // Title for the app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep), // Icon for the "Clear All" button
            onPressed: () {
              // Show a confirmation dialog before clearing all allergies
              showConfirmationDialog( 
                context,
                title: 'Clear All Allergies',  
                content: 'Are you sure you want to clear all allergies?',
                onConfirm: () {
                  Provider.of<AllergyProvider>(context, listen: false)
                      .clearAllergies();
                },
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
                    String allergy = allergyProvider.allergies[index];  // Get each allergy from the list
                    String displayAllergy = capitalizeFirstLetter(allergy);  // Capitalize first letter for display

                    // Handle Tree Nuts allergen - Display title with its corresponding nuts
                    if (allergy == 'Tree Nuts') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(displayAllergy), // Display capitalized allergy name
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),  // Delete icon button
                              onPressed: () => allergyProvider
                                  .removeAllergensOfType('Tree Nuts', allergyProvider.treeNuts), // Remove "Tree Nuts" and all corresponding nuts
                            ),
                          ),
                          ...allergyProvider.treeNuts.map((treeNut) {
                            return allergyProvider.allergies.contains(treeNut)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Indent child item
                                    child: ListTile(
                                      title: Text(capitalizeFirstLetter(treeNut)), // Display capitalized tree nut
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeAllergy(treeNut), // Remove specific tree nut
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    }
                    
                    // Handle Crustacean Shellfish allergen - Display title with its corresponding shellfish
                    else if (allergy == 'Crustacean Shellfish') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(displayAllergy), // Display capitalized allergy name
                            trailing: IconButton(
                              icon: const Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider
                                  .removeAllergensOfType('Crustacean Shellfish', allergyProvider.crustaceanShellfish), // Remove "Crust. Shell." and all corresponding allergens
                            ),
                          ),
                          ...allergyProvider.crustaceanShellfish.map((shellfish) {
                            return allergyProvider.allergies.contains(shellfish)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Indent child item
                                    child: ListTile(
                                      title: Text(capitalizeFirstLetter(shellfish)), // Display capitalized crust. shell.
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeAllergy(shellfish), // Remove specific crust. shellfish
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    }
                    
                    // Handle Fish allergen - Display title with its corresponding fish
                    else if (allergy == 'Fish') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(displayAllergy), // Display capitalized allergy name
                            trailing: IconButton(
                              icon: const Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider
                                  .removeAllergensOfType('Fish', allergyProvider.fish), // Remove "Fish" and all corresponding allergens
                            ),
                          ),
                          ...allergyProvider.fish.map((fish) {
                            return allergyProvider.allergies.contains(fish)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Indent child item
                                    child: ListTile(
                                      title: Text(capitalizeFirstLetter(fish)), // Display capitalized fish
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeAllergy(fish), // Remove specific crust. shellfish
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    }
                    
                    // Handle Legumes allergen - Display title with its corresponding legumes
                    else if (allergy == 'Legumes') {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(displayAllergy), // Display capitalized allergy name
                            trailing: IconButton(
                              icon: const Icon(Icons.delete), // Delete icon button
                              onPressed: () => allergyProvider
                                  .removeAllergensOfType('Legumes', allergyProvider.legumes), // Remove "Legumes" and all corresponding allergens
                            ),
                          ),
                          ...allergyProvider.legumes.map((legume) {
                            return allergyProvider.allergies.contains(legume)
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 16.0), // Indent child item
                                    child: ListTile(
                                      title: Text(capitalizeFirstLetter(legume)), // Display capitalized legume
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete), // Delete icon button
                                        onPressed: () => allergyProvider.removeAllergy(legume), // Remove specific legume
                                      ),
                                    ),
                                  )
                                : Container();
                          }).toList(),
                        ],
                      );
                    }
                    
                    // Handle individual (non-group) allergens
                    else if (allergyProvider.treeNuts.contains(allergy) ||
                        allergyProvider.crustaceanShellfish.contains(allergy) ||
                        allergyProvider.fish.contains(allergy) ||
                        allergyProvider.legumes.contains(allergy)) {
                        // Skip rendering individual items handled above
                      return Container();
                    } 
                    else {
                      // Display other individual allergens
                      return ListTile(
                        title: Text(displayAllergy),  // Display capitalized allergy name
                        trailing: IconButton(
                          icon: const Icon(Icons.delete), // Delete icon button
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
                            decoration: const InputDecoration(
                              labelText: 'Input Single Allergen', // Input field label
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add), // Add icon button
                          onPressed: () {
                            String newAllergy = _controller.text
                                .trim()
                                .toLowerCase(); // Normalize input to lowercase

                            if (newAllergy.isNotEmpty) { // Check if input is not empty
                              if (allergyProvider.allergies.length < maxAllergies) { // Check if not exceeding max limit
                                bool isDuplicate = allergyProvider.allergies
                                    .map((allergy) => Pluralize()
                                        .singular(allergy)
                                        .toLowerCase())  // Compare lowercase singular form to check for duplicates
                                    .contains(Pluralize().singular(newAllergy));
                                if (!isDuplicate) {
                                  allergyProvider.addAllergy(newAllergy); // Add the new allergen
                                  _controller.clear(); // Clear the input field
                                } else {
                                  showSnackBar(context,
                                      'This allergen is already in the list.');
                                }
                              } else {
                                showSnackBar(context,
                                    'You can add a maximum of 30 allergies.');
                              }
                            } else {
                              showSnackBar(context, 'Please enter a valid allergen.');
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            hint: const Text('Select Group Allergen'), // Dropdown hint text
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
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value), // Display dropdown item
                              );
                            }).toList(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),  // Add icon button
                          onPressed: () {
                            if (_selectedGroupAllergen != null) { // Check if a group allergen is selected
                              int totalAllergies = allergyProvider.allergies.length; // Total current allergies count

                              if (_selectedGroupAllergen == 'Tree Nuts') { // Add tree nuts count
                                totalAllergies += allergyProvider.treeNuts.length;
                              } else if (_selectedGroupAllergen == 'Crustacean Shellfish') { // Add crust. shellfish count
                                totalAllergies += allergyProvider.crustaceanShellfish.length;
                              } else if (_selectedGroupAllergen == 'Fish') { // Add fish count
                                totalAllergies += allergyProvider.fish.length;
                              } else if (_selectedGroupAllergen == 'Legumes') { // Add legumes count
                                totalAllergies += allergyProvider.legumes.length;
                              }

                              // Check if not exceeding max limit
                              if (totalAllergies < maxAllergies) {
                                bool isDuplicate = allergyProvider.allergies
                                    .map((allergy) => allergy.toLowerCase())
                                    .contains(_selectedGroupAllergen!.toLowerCase());
                                if (!isDuplicate) {
                                  allergyProvider.addAllergy(_selectedGroupAllergen!); // Add the selected group allergen

                                  // Check selected group allergen
                                  if (_selectedGroupAllergen == 'Tree Nuts') {
                                    allergyProvider.treeNuts.forEach((treeNut) { // For each tree nut in the list ...
                                      if (!allergyProvider.allergies.contains(treeNut)) {  //...Check if not already in allergies list
                                        allergyProvider.addAllergy(treeNut);  // Add tree nut to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Crustacean Shellfish') { 
                                    allergyProvider.crustaceanShellfish.forEach((shellfish) { // For each shellfish in the list ...
                                      if (!allergyProvider.allergies.contains(shellfish)) { //...Check if not already in allergies list
                                        allergyProvider.addAllergy(shellfish); // Add shellfish to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Fish') { 
                                    allergyProvider.fish.forEach((fish) { // For each fish in the list ...
                                      if (!allergyProvider.allergies.contains(fish)) { //...Check if not already in allergies list
                                        allergyProvider.addAllergy(fish); // Add fish to allergies list
                                      }
                                    });
                                  } else if (_selectedGroupAllergen == 'Legumes') { 
                                    allergyProvider.legumes.forEach((legume) { // For each legume in the list ...
                                      if (!allergyProvider.allergies.contains(legume)) { //...Check if not already in allergies list
                                        allergyProvider.addAllergy(legume); // Add legume to allergies list
                                      }
                                    });
                                  }
                                  setState(() {
                                    _selectedGroupAllergen = null; // Clear selected group allergen
                                  });
                                } else {
                                  showSnackBar(context,
                                      'This group allergen is already in the list.');
                                }
                              } else {
                                showSnackBar(context,
                                    'Adding this group allergen exceeds the maximum limit of 30 allergies.');
                              }
                            } else {
                              showSnackBar(context, 'Please select a group allergen.');
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
