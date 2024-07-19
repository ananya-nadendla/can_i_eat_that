import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final int totalIngredients;
  final int validatedIngredients;

  LoadingDialog({required this.totalIngredients, required this.validatedIngredients});

  @override
  Widget build(BuildContext context) {
    double progress = totalIngredients > 0 ? validatedIngredients / totalIngredients : 0;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Validating Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            LinearProgressIndicator(value: progress),
            SizedBox(height: 20),
            Text('$validatedIngredients / $totalIngredients'),
          ],
        ),
      ),
    );
  }
}
