# food_allergy_scanner

A flutter app that checks whether or not a user with allergies can eat a food product.

## Version Information

### [0.2.0] - 2024-07-05
- MINOR FEATURE
    1) Made allergens list saveable using SharedPreferences
 
- TODO:
    2) Implement "Treenuts" option (encompasses all nuts)


### [0.1.7] - 2024-07-02
- BUG FIX
  1) Prevent empty allergens list before scanning product
  2) If no text is recognized when scanning, alert user
  3) Implement "Clear All" button in ManageAllergies


### [0.1.4] - 2024-07-02
- MINOR FEATURE
- 1) If product is unsafe to eat, "See Details" option shows list of offending ingredients on another page (matching_allergen_screen)

- BUG FIX
- 1) Fixed issue with user being able to enter whitespace as allergen.
- 2) Added maximum of 20 allergens 
- 3) Made Manage / Matching Allergen pages Scrollable
- 4) Duplicate allergen entries not allowed in ManageAllergies.
    - (Ex) YouTube, Youtube, youtube, YOUTUBE, are the same
    - (Ex) You Tube, you tube, You tube, and YOU TUBE are the same


### [0.0.1] - 2024-07-01
- BUG FIX
- 1) Fixed issue with determining matches between ingredients & allergies
    - (Ex) Allergen: YouTube
        NOT MATCH: Tube, You
        MATCH: YouTube, Youtube, youtube, YOUTUBE
