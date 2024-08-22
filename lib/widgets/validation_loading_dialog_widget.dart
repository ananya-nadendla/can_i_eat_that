import 'package:flutter/material.dart';

class ValidationLoadingDialog extends StatelessWidget {
  final int totalIngredients;
  final Stream<int> progressStream;

  ValidationLoadingDialog(
      {required this.totalIngredients, required this.progressStream});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Validating Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StreamBuilder<int>(
              stream: progressStream,
              initialData: 0,
              builder: (context, snapshot) {
                int progress = snapshot.data!;
                return Column(
                  children: [
                    LinearProgressIndicator(value: progress / totalIngredients),
                    const SizedBox(height: 10),
                    Text('$progress / $totalIngredients'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
