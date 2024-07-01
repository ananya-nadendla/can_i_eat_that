import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';

class ManageAllergiesScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Allergies'),
      ),
      body: Consumer<AllergyProvider>(
        builder: (context, allergyProvider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: allergyProvider.allergies.length,
                  itemBuilder: (context, index) {
                    String allergy = allergyProvider.allergies[index];
                    return ListTile(
                      title: Text(allergy),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => allergyProvider.removeAllergy(allergy),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(labelText: 'Add Allergy'),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          allergyProvider.addAllergy(_controller.text);
                          _controller.clear();
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
