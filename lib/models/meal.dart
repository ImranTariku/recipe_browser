class Meal {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;
  final String strCategory;
  final String strArea;
  final String strInstructions;
  final String strYoutube;
  final List<String> ingredients;

  Meal({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
    required this.strCategory,
    required this.strArea,
    required this.strInstructions,
    required this.strYoutube,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Build "Ingredient - Measure" pairs
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];
      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        final m = (measure ?? '').toString().trim();
        ingredients.add(m.isEmpty ? ingredient : '$m $ingredient');
      }
    }

    return Meal(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
      strCategory: json['strCategory'] ?? '',
      strArea: json['strArea'] ?? '',
      strInstructions: json['strInstructions'] ?? '',
      strYoutube: json['strYoutube'] ?? '',
      ingredients: ingredients,
    );
  }
}

// Lightweight model used by /filter.php
class MealSummary {
  final String idMeal;
  final String strMeal;
  final String strMealThumb;

  MealSummary({
    required this.idMeal,
    required this.strMeal,
    required this.strMealThumb,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      idMeal: json['idMeal'] ?? '',
      strMeal: json['strMeal'] ?? '',
      strMealThumb: json['strMealThumb'] ?? '',
    );
  }
}