# food_allergy_scanner

A flutter app that checks whether or not a user with allergies can eat a food product by scanning the ingredients label.

## Version Information

### [0.6.2] - 2024-07-19
- BUG FIX
    1) HomeScreen --> progress bar shows correct amount of words to be validated
    2) Replaced "Vit" abbreviation with "Vitamin"

- TO DO:
    1) Match allergens against validated words list, not ingredients list
    2) Invalid word suggestions --> how to handle them? (Replace automatically, ask the user to choose, etc)
    3) Adjustable Camera Viewfinder when taking photo 
    4) UI Design


### [0.6.0] - 2024-07-19
- MINOR UPDATE
    1) Progress bar that loads while ingredients are being scanned
    2) Used concurrency for faster ingredient-dictionary validation

- BUG FIX
    1) Duplicate group allergen snackbar error - accidentally removed earlier, now put back
    2) Made README more readable

### [0.5.5] - 2024-07-19
- BUG FIX
    1) Made ingredient validation logic simpler (performance is faster now)
    2) Use both Webster's medical / collegiate dictionary for word validation (medical handles words like "degermed")
    3) Put API Key in enviroment variables file (.env)
    4) Made .env_sample to show how to import API keys
    5) Added "USAGE / Enviroment Configuration" section to README


### [0.5.0] - 2024-07-17
- MINOR UPDATE
    1) Crossreference each scanned ingredient with Merriam Webster Dictionary API
        (a) If >= 90% of words are validated, ingredient-allergen matching logic ensues
        (b) If <90% of words are valid, "photo is unclear" message is shown
        (c) (BACKEND)
            (c.i) If word is invalid, closest suggestions are listed
            (c.ii) Finds best suggestion using string_similarity package


### [0.4.8] - 2024-07-10
- BUG FIX
    1) Allergens are formatted to Title Case on MatchingAllergensScreen 
    2) Red Warning Icon next to matching allergen in MatchingAllergensScreen
        (a) (Note) Debugging - put back printed ingredients (accidentally removed in earlier version)


### [0.4.6] - 2024-07-10
- BUG FIX
    1) Duplicate Plurals - user cannot enter either singular / plural version of same allergen
    2) Formatting - allergen is formatted to Title Case regardless of how user capitalized 
        (note: lowercase still used for comparison)
    3) Solve issue of no matching because of plurals 
        (a) (i.e user enters "Almonds" but ingredients say "Almond")
        (b) (i.e user enters "Anchovy" but ingredients say "Anchovies")
        (c) (i.e user enters "Molasses" which is already in singular / plural form)
    4) Fixed - App wouldn't render allergens from a food group that user entered seperately through TextField 
        (Ex) User entered Anchovies in TextField (included in Fish Food Group), but wouldn't show on screen
    5) Updated Max Allergies to 30 allergens 
    6) Fixed - User was able to add more than 30 allergies if (current allergies) was < 30 and (wanted allergies + current allergies ) > 30


### [0.4.0] - 2024-07-08
- MINOR FEATURE
    1) Added "Crustacean Shellfish", "Legumes", and "Fish" to food group allergy in Dropdown with "Tree Nuts"


### [0.3.1] - 2024-07-07
- BUG FIX
    1) Removed "Tree Nuts" feature from TextField and turned it into DropDown feature for easier UI.


### [0.3.0] - 2024-07-05
- MINOR FEATURE
    1) Included "Treenuts" option encompassing all nuts
 

- BUG FIX
    1) Made "treenuts" and "tree nuts" both recognizable as Tree Nuts


### [0.2.0] - 2024-07-05
- MINOR FEATURE
    1) Made allergens list saveable using SharedPreferences


### [0.1.7] - 2024-07-02
- BUG FIX
  1) Prevent empty allergens list before scanning product
  2) If no text is recognized when scanning, alert user
  3) Implement "Clear All" button in ManageAllergies


### [0.1.4] - 2024-07-02
- MINOR FEATURE
    1) If product is unsafe to eat, "See Details" option shows list of offending ingredients on another page (matching_allergen_screen)

- BUG FIX
    1) Fixed issue with user being able to enter whitespace as allergen.
    2) Added maximum of 20 allergens 
    3) Made Manage / Matching Allergen pages Scrollable
    4) Duplicate allergen entries not allowed in ManageAllergies.
        (a) (Ex) YouTube, Youtube, youtube, YOUTUBE, are the same
        (b) (Ex) You Tube, you tube, You tube, and YOU TUBE are the same


### [0.0.1] - 2024-07-01
- BUG FIX
    1) Fixed issue with determining matches between ingredients & allergies
        (Ex) Allergen: YouTube
            NOT MATCH: Tube, You
            MATCH: YouTube, Youtube, youtube, YOUTUBE

## Usage
### Environment Configuration

This project uses an environment file (`.env`) to store API Keys for security purposes.

#### Setting Up the `.env` File

1. **Copy the Sample File:**

   Create a copy of the `.env_sample` file and name it `.env` in the root directory of your project.

2.  **Sign Up For Merriam-Webster API**

    Sign Up Link: https://dictionaryapi.com/register/index
    - For or "Request API Key (1)", choose "Collegiate Dictionary" from dropdown
    - For "Request API Key (2)", choose "Medical Dictionary" from dropdown


4. **Add Your API Keys:**

   Open the `.env` file and replace the placeholder values with your actual API keys. For example:

   ```plaintext
   # Your Merriam-Webster Collegiate API Key
   API_KEY_MERRIAM_WEBSTER_COLLEGIATE_DICTIONARY=your_actual_collegiate_api_key

   # Your Merriam-Webster Medical API Key
   API_KEY_MERRIAM_WEBSTER_MEDICAL_DICTIONARY=your_actual_medical_api_key

