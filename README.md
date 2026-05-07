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
- Search debouncing (400ms delay) 
- Search bar on home screen – searches all meals globally

## 🎥 Screen Recording

**Video link:** [Click here to watch the demo](https://drive.google.com/file/d/1kIBwF62uub6SG3kCJPieqLjEz2rvkcd6/view?usp=sharing)

*The video demonstrates: loading categories, searching with debouncing, meal details, error handling (no internet), and retry button functionality.*

---

## 🏗️ Architectural Design

The app follows a clean separation of concerns as required by the assignment:

| Layer | Location | Responsibility |
|-------|----------|----------------|
| **UI Layer** | `lib/screens/` | Displays screens using `FutureBuilder`. Handles loading, error, and data states. |
| **Service Layer** | `lib/services/` | `MealApiService` makes all HTTP calls. Contains `_baseUrl`, `_timeout`, `_checkResponse`. Throws `ApiException`. |
| **Model Layer** | `lib/models/` | `MealCategory` and `Meal` classes with `final` fields, `fromJson`, `toJson`, and `copyWith`. |
| **Error Handling** | Global | Catches `SocketException`, `TimeoutException`, `FormatException`. Displays Retry button. |

### Data Flow
1. User opens app → `CategoriesScreen` → `FutureBuilder` calls `fetchCategories()`
2. Success → displays category grid
3. Tap category → navigates to `MealsScreen` → fetches meals
4. Tap meal → navigates to `MealDetailScreen` → fetches full recipe
5. Search → **400ms debounce** → calls `searchMeals()` API
6. Error (no internet) → error message + Retry button → retry re‑calls API

---

## ✅ Assignment Requirements Checklist

| Requirement | Status |
|-------------|--------|
| `http` package, `Uri.https()` | ✅ |
| 10‑second timeout | ✅ |
| Custom `ApiException` | ✅ |
| Models with `fromJson`, `toJson`, `copyWith`, final fields | ✅ |
| Dedicated service class in `lib/services/` | ✅ |
| No HTTP calls in UI | ✅ |
| `FutureBuilder` with loading/error/no-data/data | ✅ |
| Retry button on error | ✅ |
| Error handling (Socket, Timeout, Format, generic) | ✅ |
| Project folder structure | ✅ |
| README with all 6 required items | ✅ |
| 5+ Git commits | ✅ |
| Screen recording (2+ min) showing all flows + error + retry | ✅ |
| Public GitHub repo | ✅ |
| **Bonus: Search debouncing** | ✅ |

---

## 📦 Git Commits
## 📦 Git Commits

- `5b1d4c7` – Add README with name, ID, and track details
- `5d12a47` – Improve card shadow
- `638327c` – Add emoji to app title
- `391b09f` – Improve search hint text
- `8961f8a` – Add header comment to API service
- `08f9966` – Initial commit: recipe browser app