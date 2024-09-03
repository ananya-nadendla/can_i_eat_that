## Version Information

### [0.12.6] - 2024-09-02
- MINOR UPDATE
    1) Renamed project from "Food Allergy Scanner" (food_allergy_scanner) to "Can I Eat That" (can_i_eat_that)

- BUG FIX
    1) Put Version Information in a CHANGELOG.md
    2) README - Wrote section on : App Installation from GitHub
    3) Removed unused "Themes" Folder and "themes/app_theme.dart" (ThemeData is in main.dart)
    4) Image Deletion occurs on...
        - Camera Screen: 
            - Camera capturing error
            - Image Retake
            - Image Cancellation
        - Crop Screen
            - Cropping Cancellation
        - Home Screen
            - Result: "Photo is unclear"
            - Result: "Product is safe to eat"
            - Result: "Product contains allergens"
            - Result: "No text recognized"
    5) Added Privacy Policy (for image deletion) in README
    6) README - Added app screenshots

- TO DO:
    1) README: Add app demo / screenshots
    2) Neaten debugging print statements + replace with loggers
    3) CHANGELOG: Format all Version Information 

### [0.11.3] - 2024-09-02
- BUG FIX
    1) Home Screen - Fixed "Scan Result" dialog overflow issue when phone = landscape mode
    2) Camera Screen - fixed button formatting when phone = landscape mode
    3) AndroidManifest.xml - Locked phone in portrait mode
        - Note: Added updates to landscape mode, then locked app in portrait mode, so that UI is responsive to different phone sizes in all/extreme cases.
    4) (IMPORTANT) Figure out how to run in release mode (update kotlin)


### [0.11.0] - 2024-09-01
- MINOR FEATURE (APP UI)
    1) Cohesive color palette across all screens using ThemeData in main.dart
    2) Centered all Screen Titles
    2) Home Screen
        - Added image of person with magnifying glass
    3) Manage Allergies Screen 
        - Modified "add allergen" plus sign icons to have circle behind it
        - Made both input fields uniform
        - Added rectangle around both input fields
        - Cursor (when typing in Text Field) is purple
        - All appbar icons (back arrow, clear all trash) is same color (cream)
        - Background color behind input fields is darker than that of allergen list
    4) Processing Dialog / Validation Loading Dialog
        - Manually added theme colors for readability
    5) Camera Screen
        - Turned camera button red & purple

### [0.10.1] - 2024-08-30
- MINOR FEATURE
    - Created and imported app icon

- BUG FIX
    - Disabled "Crop" button until crop_your_image widget loads in (in Crop Screen)

### [0.9.21] - 2024-08-30
- BUG FIX
    1) Made Special Case where "and" is not removed in the phrase "Natural and Artificial"
        - (Note: This addresses note in v0.9.13)
    2) HomeScreen Rework
        - (2.a) Added method normalizeIngredients() - removed redundant ingredient normalization in scanProduct() and validateIngredients()
        - (2.b) Updated scanProduct() matching logic to be less redundant
        - (2.c) Added method findMatches() - Made matching logic in scanProduct() it's own method
        - (2.d) Comments added + formatting
    3) Cleaned up unused dependencies in pubspec.yaml & unused methods in services/merriam_webster_service
    5) Comments added + formatting for:
        - CropScreen
        - ManageAllergiesScreen
        - MatchingAllergensScreen
        - Utils, Processing_Dialog
        - ValidationLoadingDialog
        - Main.dart
        - CameraScreen
    6) ProcessingDialog & ValidationLoadingDialog - changed title messages to make more user friendly

### [0.9.13] - 2024-08-29
- BUG FIX
    1) Removed back navigation on CropScreen/CameraScreen (replaced deprecated onWillPop with canPop)
    2) CropScreen - Added CircularLoadingIndicator during the pause that occurs after user hits "Continue"
    3) CropScreen - Modified buttons to match Camera UI
    4) HomeScreen - Modified ingredient normalization
        - Set ingredients to lowercase for easier normalization
        - Removed phrase "and/or" from ingredients list (along with "and" and "or")
    5) CameraScreen - Fixed glitchy bottom message + padding
        - Solved Issue: Bottom message kept switching from left-align to center-align
        - Solved Issue: Static padding values made camera preview offcentered

- NOTES:
    1) Removal of "And", "Or", "And/Or"
        - Splits phrase like "Wheat and Oat" into two ingredients: "Wheat", "Oat"
        - Issue: Splits "Natural and Artifical Flavouring" into "Natural", "Artifical Flavouring"


### [0.9.8] - 2024-08-28
- BUG FIX
    1) Disabled Continue button (in Crop Screen) once pressed (because multiple presses leads to error)
    2) Upgraded Camera UI - Added Capture / Retake / Cancel / Approve buttons 
    3) Buggy API Calls - Added batch processing (to validateIngredients() in HomeScreen) 
        - Previous Implementation: Made API Calls for all words concurrently
            - Issue: Lag, 504 Errors
        - New Implementation: Batch of 5 words, Smoother/Faster performance

### [0.9.5] - 2024-08-27
- MINOR FEATURE
    - Upgraded Flutter ("flutter upgrade"), including dependencies

- BUG FIX
    1) Camera - Updated Camera UI to look like Image Cropper UI
        - Note: Padding issues
    2) Permissions Bug - App no longer asks for audio access 
    3) Permission Denial - App checks if camera permissions is denied
        - If denied, two options shown: "Settings" and "Ok"
        - "Ok": Leads to HomeScreen
        - "Settings": Leads to Settings app where user can change permissions
    4) Made cropping handles further away from edge of screen (to avoid accidental swiping backwards gesture)


### [0.8.13] - 2024-08-24
- BUG FIX
    1) Removed duplicate ingredients from ingredients list
    2) Improved image cropper 
        - Replaced image_cropper package with crop_your_image package
        - Created crop_image_screen.dart
        - Included instruction message @ bottom of the screen



### [0.8.11] - 2024-08-22
- BUG FIX
    1) Added utils.dart + integrated into screens files
    2) Added const modifiers
    3) Added CircularProgressIndicator on HomeScreen
        - Displays behind all UI elements (camera, image cropper, processingDialog widget, validationLoadingDialog widget)
        - Reverts back to regular HomeScreen when
            - (1) User cancels camera / cropper
            - (2) Scan Results AlertDialog
    4) Formatted all lib files
    5) Consolidated redundant methods in allergy_provider + integrated updates into manageAllergies

- NOTES / OBSERVATIONS
    1) User enters mispelled allergen + same mispelled allergen is scanned --> Allergen goes under both "Unsafe" and "Unrecognized" in Results page

### [0.8.6] - 2024-08-21
- BUG FIX
    1) More thorough normalization of ingredients list
        - extracted words list from ingredients list, rather than both being extracted seperately from the scanned text
        - above is useful for removed words (i.e "ingredients" or "and / or")
    2) Used same [ingredient / word extraction from scanned text] logic for validateIngredients() and scanProduct()
    3) Better formatting + comments

### [0.8.3] - 2024-08-20       
- BUG FIX
    1) Removed Keywords (from ingredients list)
        - Already Implemented: "Ingredient", "Ingredients"
        - Added: "Contains", "Or Less Of", "May contain"
    2) Ingredient Splitters - Added more (splitters are removed from ingred. list)
        - Colons 
        - "And"
        - "Or"

### [0.8.1] - 2024-08-20
- MINOR FEATURE
    1) Image cropping feature after user captures photo 
        - (so that they only capture the text they wish)
        
- BUG FIX
    1) User is sent to home screen if they cancel image cropping feature

### [0.7.11] - 2024-07-30
- BUG FIX
    1) Fixed - invalid ingredients aren't part of the safe ingredient list anymore
    2) Removed the words "ingredient(s)" from printing on the Results page as an ingredient itself
    3) "See Details" now shows even if there are no matching allergens
    4) Fixed - user cancels image picker, screen turns black



### [0.7.7] - 2024-07-28
- BUG FIX
    1) Safe ingredient is shown in Matching Allergens Screen 
    2) Newline characters replaced w/ single space in ingredients list 
    3) Whole invalid ingredient is shown in Matching Allergens Screen (not just invalid word)


### [0.7.4] - 2024-07-24
- BUG FIX 
    1) Invalid words (aka. scanned ingredients not found in dictionary) show in Matching Allergens Screen
        - (note: ) occurs when warning that between 90 and 100 words were shown
    2) '&' does not count as punctuation in removeWordPunctuation, is permissible (in the case of words like fd&c)
    3) Renamed widget files better (LoadingDialog to ValidationLoadingDialog)
    4) Removed duplicate ValidationLoadingDialog in home_screen and instead imported widgets/validation_loading_dialog


### [0.7.0] - 2024-07-24
- MINOR FEATURE
    - Another loading spinner (processing_dialog_widget.dart) signifying ingredients being scanned (before validation loading_dialog_widget.dart)

### [0.6.6] - 2024-07-23
- BUG FIX
    1) Changed counter to show # of words being validated, NOT number of valid words
        (note) : loading bar works properly
    2) Made pre-validation for special words (abbreviations: vit, fd&c)
        (a) REMOVED: Replaced "Vit" abbreviation with "Vitamin"
    3) If 90%+ (excluding 100%) words were validated, a warning message is shown that not all words were recognized.
    4) Put back Snackbar error - enter allergen before scanning product


### [0.6.2] - 2024-07-19
- BUG FIX
    1) HomeScreen --> progress bar shows correct amount of words to be validated
    2) Replaced "Vit" abbreviation with "Vitamin"
    (note) DID NOT IMPLEMENT [Match allergens against validated words list, not ingredients list] because "White Wine Vinegar" is "White", "Wine", "Vinegar"


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
