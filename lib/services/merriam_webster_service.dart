import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';

class MerriamWebsterService {
  final String apiKey = 'c5e6d4c9-0c7d-484a-b5c6-f39654e487ed'; // Replace with your Merriam-Webster API key

  Future<bool> isValidWord(String word) async {
    final String url = 'https://www.dictionaryapi.com/api/v3/references/collegiate/json/$word?key=$apiKey';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // Check if the response contains definitions
        if (jsonResponse.isNotEmpty && jsonResponse[0] is Map) {
          return true;
        } else {
          print('No definitions found for "$word".');
        }
      } else if (response.statusCode == 403) {
        print('Invalid API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch definition for "$word". Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching definition for "$word": $e');
    }

    return false;
  }

  Future<List<String>> getSuggestions(String word) async {
    final String url = 'https://www.dictionaryapi.com/api/v3/references/collegiate/json/$word?key=$apiKey';

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        // If the response is a list of strings, it contains suggestions
        if (jsonResponse.isNotEmpty && jsonResponse[0] is String) {
          List<String> suggestions = List<String>.from(jsonResponse);

          // Find and print the closest suggestion
          String closestSuggestion = StringSimilarity.findBestMatch(word, suggestions).bestMatch.target!;
          print('Closest suggestion for "$word" is "$closestSuggestion".');

          return suggestions;
        }
      } else if (response.statusCode == 403) {
        print('Invalid API key or not subscribed for this reference.');
      } else {
        print('Failed to fetch suggestions for "$word". Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching suggestions for "$word": $e');
    }

    return [];
  }
}
