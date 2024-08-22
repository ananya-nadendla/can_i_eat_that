import 'package:flutter/material.dart';

/// Capitalizes the first letter of each word in a given string.
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return '';
  return text
      .toLowerCase()
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

/// Shows a SnackBar with the given [message] in the provided [context].
void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

/// Shows a confirmation dialog with [title] and [content] text.
/// If the user confirms, [onConfirm] will be executed.

Future<void> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required VoidCallback onConfirm,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // Cancel button
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(); // Execute the confirmation action
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Clear All'),
        ),
      ],
    ),
  );
}
