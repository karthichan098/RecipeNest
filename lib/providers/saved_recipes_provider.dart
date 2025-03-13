import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe.dart';

class SavedRecipesProvider extends ChangeNotifier {
  List<Recipe> _savedRecipes = [];

  List<Recipe> get savedRecipes => _savedRecipes;

  SavedRecipesProvider() {
    _loadSavedRecipes();
  }

  void _loadSavedRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('saved_recipes');

    if (savedData != null) {
      List<dynamic> decoded = json.decode(savedData);
      _savedRecipes = decoded.map((data) => Recipe.fromJson(data)).toList();
      notifyListeners();
    }
  }

  void _saveToStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> savedList = _savedRecipes.map((r) => r.toJson()).toList();
    await prefs.setString('saved_recipes', json.encode(savedList));
  }

  void toggleSaveRecipe(Recipe recipe) {
    if (_savedRecipes.any((r) => r.id == recipe.id)) {
      _savedRecipes.removeWhere((r) => r.id == recipe.id);
    } else {
      _savedRecipes.add(Recipe(
        id: recipe.id,
        name: recipe.name,
        category: recipe.category,
        image: recipe.image,
        instructions: recipe.instructions,
        ingredients: List.from(recipe.ingredients), // Ensure ingredients are saved
        isVegetarian: recipe.isVegetarian,
        isSaved: true,
      ));
    }
    _saveToStorage();
    notifyListeners();
  }
}