import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MerriamWebsterService {
  // Use dotenv to fetch API keys from .env file
  final String collegiateApiKey = dotenv.env['API_KEY_MERRIAM_WEBSTER_COLLEGIATE_DICTIONARY']!;
  final String medicalApiKey = dotenv.env['API_KEY_MERRIAM_WEBSTER_MEDICAL_DICTIONARY']!;

  // Function to check if a word is valid
  Future<bool> isValidWord(String word) async {
    final String collegiateUrl = 'https://www.dictionaryapi.com/api/v3/references/collegiate/json/$word?key=$collegiateApiKey';
    
    try {
      final http.Response collegiateResponse = await http.get(Uri.parse(collegiateUrl));

      if (collegiateResponse.statusCode == 200) {
        final List<dynamic> collegiateJsonResponse = json.decode(collegiateResponse.body);

        // Check if the response contains definitions
        if (collegiateJsonResponse.isNotEmpty && collegiateJsonResponse[0] is Map) {
          return true;
        } else {
          print('No definitions found for "$word" in collegiate dictionary.');
        }
      } else if (collegiateResponse.statusCode == 403) {
        print('Invalid collegiate API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch definition for "$word" from collegiate dictionary. Status code: ${collegiateResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching definition for "$word" from collegiate dictionary: $e');
    }

    // If the word is not found in the collegiate dictionary, check the medical dictionary
    final String medicalUrl = 'https://www.dictionaryapi.com/api/v3/references/medical/json/$word?key=$medicalApiKey';
    
    try {
      final http.Response medicalResponse = await http.get(Uri.parse(medicalUrl));

      if (medicalResponse.statusCode == 200) {
        final List<dynamic> medicalJsonResponse = json.decode(medicalResponse.body);

        // Check if the response contains definitions
        if (medicalJsonResponse.isNotEmpty && medicalJsonResponse[0] is Map) {
          return true;
        } else {
          print('No definitions found for "$word" in medical dictionary.');
        }
      } else if (medicalResponse.statusCode == 403) {
        print('Invalid medical API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch definition for "$word" from medical dictionary. Status code: ${medicalResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching definition for "$word" from medical dictionary: $e');
    }

    return false;
  }

  // Function to get suggestions for a word
  Future<List<String>> getSuggestions(String word) async {
    final String collegiateUrl = 'https://www.dictionaryapi.com/api/v3/references/collegiate/json/$word?key=$collegiateApiKey';
    
    try {
      final http.Response collegiateResponse = await http.get(Uri.parse(collegiateUrl));

      if (collegiateResponse.statusCode == 200) {
        final List<dynamic> collegiateJsonResponse = json.decode(collegiateResponse.body);

        // If the response is a list of strings, it contains suggestions
        if (collegiateJsonResponse.isNotEmpty && collegiateJsonResponse[0] is String) {
          List<String> suggestions = List<String>.from(collegiateJsonResponse);

          // Find and print the closest suggestion
          String closestSuggestion = StringSimilarity.findBestMatch(word, suggestions).bestMatch.target!;
          print('Closest suggestion for "$word" in collegiate dictionary is "$closestSuggestion".');

          return suggestions;
        }
      } else if (collegiateResponse.statusCode == 403) {
        print('Invalid collegiate API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch suggestions for "$word" from collegiate dictionary. Status code: ${collegiateResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions for "$word" from collegiate dictionary: $e');
    }

    // If no suggestions are found in the collegiate dictionary, check the medical dictionary
    final String medicalUrl = 'https://www.dictionaryapi.com/api/v3/references/medical/json/$word?key=$medicalApiKey';
    
    try {
      final http.Response medicalResponse = await http.get(Uri.parse(medicalUrl));

      if (medicalResponse.statusCode == 200) {
        final List<dynamic> medicalJsonResponse = json.decode(medicalResponse.body);

        // If the response is a list of strings, it contains suggestions
        if (medicalJsonResponse.isNotEmpty && medicalJsonResponse[0] is String) {
          List<String> suggestions = List<String>.from(medicalJsonResponse);

          // Find and print the closest suggestion
          String closestSuggestion = StringSimilarity.findBestMatch(word, suggestions).bestMatch.target!;
          print('Closest suggestion for "$word" in medical dictionary is "$closestSuggestion".');

          return suggestions;
        }
      } else if (medicalResponse.statusCode == 403) {
        print('Invalid medical API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch suggestions for "$word" from medical dictionary. Status code: ${medicalResponse.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions for "$word" from medical dictionary: $e');
    }

    return [];
  }
}
