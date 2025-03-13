import 'dart:convert';

class Recipe {
  final String id;
  final String name;
  final String category;
  final String image;
  final String instructions;
  final List<String> ingredients;
  final bool isVegetarian;
  bool isSaved; // Track saved state

  Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.image,
    required this.instructions,
    required this.ingredients,
    required this.isVegetarian,
    this.isSaved = false,
  });

  /// ✅ **Updated `fromJson` method**
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? 'Unknown',
      image: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients']) // ✅ Correctly restores list from saved data
          : _extractIngredients(json), // ✅ Extracts from API response if `ingredients` is missing
      isVegetarian: json['isVegetarian'] ?? false,
    );
  }

  /// ✅ **Extract ingredients from API response**
  static List<String> _extractIngredients(Map<String, dynamic> json) {
    List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      String? ingredient = json['strIngredient$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add(ingredient);
      }
    }
    return ingredients;
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strMealThumb': image,
      'strInstructions': instructions,
      'ingredients': ingredients, // ✅ Saves list directly
      'isVegetarian': isVegetarian,
      'isSaved': isSaved,
    };
  }
}
