# can_i_eat_that

A flutter app that checks whether or not a user with allergies can eat a food product by scanning the ingredients label.

## Features

- **Quick Allergen Scanning:** Efficiently check an ingredients label for allergens.
- **Customizable Allergen List:** Add and remove your allergens as needed.
- **Color-Coded Results:** Clear, color-coded messages to indicate safety.
- **Simple UI:** A simple and intuitive user interface for an easy user experience.

## Installation

To get started with this project, follow these steps:

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/ananya-nadendla/can_i_eat_that.git
   ```

2. **Navigate to the Project Directory:**

   ```bash
   cd can_i_eat_that
   ```

3. **Install Dependencies:**

   Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed. Then, run:

   ```bash
   flutter pub get
   ```

4. **Set Up Environment Variables:**

   Follow the instructions in the [**Environment Configuration**](#environment-configuration) section to set up your `.env` file.

5. **Run the App:**

   ```bash
   flutter run
   ```

## Usage
### Environment Configuration

This project uses an environment file (`.env`) to store API Keys for security purposes.

#### Setting Up the `.env` File

1. **Copy the Sample File:**

   Create a copy of the `.env_sample` file and name it `.env` in the root directory of your project.

2.  **Sign Up For Merriam-Webster API**

    Sign Up Link: https://dictionaryapi.com/register/index **(its free!)**
    - For "Request API Key (1)", choose "Collegiate Dictionary" from dropdown
    - For "Request API Key (2)", choose "Medical Dictionary" from dropdown


4. **Add Your API Keys:**

   Open the `.env` file and replace the placeholder values with your actual API keys. For example:

   ```plaintext
   # Your Merriam-Webster Collegiate API Key
   API_KEY_MERRIAM_WEBSTER_COLLEGIATE_DICTIONARY=your_actual_collegiate_api_key

   # Your Merriam-Webster Medical API Key
   API_KEY_MERRIAM_WEBSTER_MEDICAL_DICTIONARY=your_actual_medical_api_key
