# Recipe Browser

**Name:** Imran Tariku  
**Student ID:** ATE/9968/15  
**Track:** C – Recipe Browser (TheMealDB API)

## Description
A Flutter app that displays meal categories, allows searching for recipes (with debouncing), and shows full meal details including ingredients, instructions, and YouTube links.

## How to run locally
1. Ensure Flutter is installed.
2. Clone the repository:  
   `git clone https://github.com/ImranTariku/recipe_browser.git`
3. Navigate to the project folder and run `flutter pub get`.
4. Run the app: `flutter run -d chrome` (or on an Android emulator).

## API Endpoints used
- `GET /categories.php` – fetch all meal categories
- `GET /filter.php?c={category}` – fetch meals in a category
- `GET /lookup.php?i={id}` – fetch full meal details
- `GET /search.php?s={query}` – search meals (bonus)

## Known limitations / bugs
- No internet connection triggers error message with Retry button (works as required).
- Some meal images may be low quality (TheMealDB limitation).
- Search debouncing (400ms) prevents excessive API calls.

## Bonus features
- Search debouncing (400ms delay) – +5 marks
- Search bar on home screen – searches all meals globally