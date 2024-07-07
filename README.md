# food_allergy_scanner

A flutter app that checks whether or not a user with allergies can eat a food product.

## Version Information

### [0.3.1] - 2024-07-07
- BUG FIX
    1) Removed "Tree Nuts" feature from TextField and turned it into DropDown feature for easier UI.

- TODO:
    1) Solve issue of plurals (i.e user enters "Almonds" but ingredients say "Almond")
    2) Format user's capitalization errors (i.e HOney shows up as Honey)
    2) Use same Tree Nut concept for one other one-word-encompassing allergen descriptors (crustacean, dairy, etc)


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
