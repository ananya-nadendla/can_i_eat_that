import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:can_i_eat_that/utils/utils.dart';

class MerriamWebsterService {
  // Use dotenv to fetch API keys from .env file
  final String collegiateApiKey =
      dotenv.env['API_KEY_MERRIAM_WEBSTER_COLLEGIATE_DICTIONARY']!;
  final String medicalApiKey =
      dotenv.env['API_KEY_MERRIAM_WEBSTER_MEDICAL_DICTIONARY']!;

  // Function to check if a word is valid
  Future<bool> isValidWord(String word) async {
    final String collegiateUrl =
        'https://www.dictionaryapi.com/api/v3/references/collegiate/json/$word?key=$collegiateApiKey';

    try {
      final http.Response collegiateResponse =
          await http.get(Uri.parse(collegiateUrl));

      if (collegiateResponse.statusCode == 200) {
        final List<dynamic> collegiateJsonResponse =
            json.decode(collegiateResponse.body);

        // Check if the response contains definitions (aka. word exists)
        if (collegiateJsonResponse.isNotEmpty &&
            collegiateJsonResponse[0] is Map) {
          return true;
        } else {
          LoggerUtil.logger.d('No definitions found for "$word" in collegiate dictionary.');
        }
      } else if (collegiateResponse.statusCode == 403) {
        LoggerUtil.logger.e('Invalid collegiate API key or not subscribed for this reference.');
      } else {
        LoggerUtil.logger.e('Failed to fetch definition for "$word" from collegiate dictionary. Status code: ${collegiateResponse.statusCode}');
      }
    } catch (e) {
      LoggerUtil.logger.e('Error fetching definition for "$word" from collegiate dictionary: $e');
    }

    // If the word is not found in the collegiate dictionary, check the medical dictionary
    final String medicalUrl =
        'https://www.dictionaryapi.com/api/v3/references/medical/json/$word?key=$medicalApiKey';

    try {
      final http.Response medicalResponse =
          await http.get(Uri.parse(medicalUrl));

      if (medicalResponse.statusCode == 200) {
        final List<dynamic> medicalJsonResponse =
            json.decode(medicalResponse.body);

        // Check if the response contains definitions (aka. word exists)
        if (medicalJsonResponse.isNotEmpty && medicalJsonResponse[0] is Map) {
          return true;
        } else {
          LoggerUtil.logger.d('No definitions found for "$word" in medical dictionary.');
        }
      } else if (medicalResponse.statusCode == 403) {
        LoggerUtil.logger.e('Invalid medical API key or not subscribed for this reference.');
      } else {
        LoggerUtil.logger.e('Failed to fetch definition for "$word" from medical dictionary. Status code: ${medicalResponse.statusCode}');
      }
    } catch (e) {
      LoggerUtil.logger.e('Error fetching definition for "$word" from medical dictionary: $e');
    }

    return false;
  }

}
