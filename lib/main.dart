import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure binding is initialized before running app

  // Load environment variables (api keys)
  try {
    await dotenv.load(
        fileName: ".env"); // Load environment variables from the .env file
    print('Environment variables loaded successfully.');
  } catch (e) {
    print(
        'Error loading environment variables: $e'); // Environment variable loading failed
  }
  runApp(const MyApp()); // Run the main application widget
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Constructor for MyApp widget

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // List of providers for managing state across the app
        ChangeNotifierProvider(
            create: (_) =>
                AllergyProvider()), // Provider for managing allergies
      ],
      child: MaterialApp(
        title: 'Food Allergy Scanner', // App title
        theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 29, 87, 31), // Primary color
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 253, 208), // Background color for the scaffold
          colorScheme: const ColorScheme(
            primary: Color.fromARGB(255, 255, 253, 208), // Primary color for app components
            secondary: Color.fromARGB(255, 101, 156, 103), // Secondary color
            surface: Color.fromARGB(255, 101, 156,103), // Custom color for surfaces like cards - buttons
            error: Colors.red, // Color for error messages
            onPrimary: Color.fromARGB(255, 255, 253, 208), // Color for text on primary color
            onSecondary: Colors.brown, // Color for text on secondary color
            onError: Colors.white, // Color for text on error color
            onSurface: Color.fromARGB(255, 90, 6, 100), // Color for text on surface color
            brightness: Brightness.light, // Light Theme mode 
          ),

          //Theme for App Bar
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 101, 156, 103), // Background color for AppBar
            titleTextStyle: const TextStyle(color: Color.fromARGB(255, 255, 253, 208), // Text color for AppBar title
              fontSize: 20, // Font size for AppBar title
              fontWeight: FontWeight.bold, // Font weight for AppBar title
            ),
            iconTheme: IconThemeData(
              color: Color.fromARGB(255, 255, 253, 208), // Replace with your desired color
            ),
          ),

          // Snack Bar Theme
          snackBarTheme: const SnackBarThemeData(
            contentTextStyle: TextStyle(
              color: Color.fromARGB(255, 255, 253, 208), // Text color of the SnackBar
              fontSize: 16, // Font size of the SnackBar text
            ),
          ),

          // Dialog Theme
          dialogTheme: const DialogTheme(
            backgroundColor: Color.fromARGB(255, 255, 253, 208),
            titleTextStyle: TextStyle(
              color: Color.fromARGB(255, 76, 123, 78), // Text color for the dialog title
              fontSize: 20, // Font size for the dialog title
              fontWeight: FontWeight.bold, // Font weight for the dialog title
            ),
            contentTextStyle: TextStyle(
              color: Color.fromARGB(255, 90, 6, 100), // Text color for the dialog content
              fontSize: 16, // Font size for the dialog content
            ),
          ),

          // TextButton theme (used in Dialog "Cancel" or "OK" buttons)
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              foregroundColor: ButtonStyleButton.allOrNull<Color>(
                  const Color.fromARGB(255, 90, 6, 100)), // Text color for buttons
              backgroundColor: ButtonStyleButton.allOrNull<Color>(
                  const Color.fromARGB(255, 134, 185, 136)), // Background color for buttons
              overlayColor: ButtonStyleButton.allOrNull<Color>(
                  Colors.lightGreen.withOpacity(0.1)), // Ripple color
            ),
          ),
        ),
        home: HomeScreen(), // Initial screen of the app
      ),
    );
  }
}
