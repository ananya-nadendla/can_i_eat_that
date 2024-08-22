import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  try {
    await dotenv.load(fileName: ".env");
    print('Environment variables loaded successfully.');
  } catch (e) {
    print('Error loading environment variables: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
