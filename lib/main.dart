import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized before running app

  //Load enviroment variables (api keys)
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables from the .env file
    print('Environment variables loaded successfully.');
  } catch (e) {
    print('Error loading environment variables: $e'); //Enviroment variable loading failed
  }
  runApp(const MyApp()); // Run the main application widget
} 

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);  // Constructor for MyApp widget

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
          primarySwatch: Colors.blue, // Theme color
        ),
        home: HomeScreen(), // Initial screen of the app
      ),
    );
  }
}
