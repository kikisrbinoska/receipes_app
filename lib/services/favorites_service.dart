import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meal.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_meals';

  // Get all favorite meal IDs
  Future<Set<String>> getFavoriteMealIds() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    return favorites.toSet();
  }

  // Check if a meal is favorite
  Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavoriteMealIds();
    return favorites.contains(mealId);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String mealId, String mealName, String mealThumb) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_favoritesKey) ?? [];
    final favoritesSet = favorites.toSet();

    if (favoritesSet.contains(mealId)) {
      favoritesSet.remove(mealId);
      await _removeFavoriteMeal(mealId);
    } else {
      favoritesSet.add(mealId);
      await _saveFavoriteMeal(mealId, mealName, mealThumb);
    }

    await prefs.setStringList(_favoritesKey, favoritesSet.toList());
    return favoritesSet.contains(mealId);
  }

  // Save favorite meal details
  Future<void> _saveFavoriteMeal(String mealId, String mealName, String mealThumb) async {
    final prefs = await SharedPreferences.getInstance();
    final mealData = {
      'idMeal': mealId,
      'strMeal': mealName,
      'strMealThumb': mealThumb,
    };
    await prefs.setString('meal_$mealId', json.encode(mealData));
  }

  // Remove favorite meal details
  Future<void> _removeFavoriteMeal(String mealId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('meal_$mealId');
  }

  // Get all favorite meals
  Future<List<Meal>> getFavoriteMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteMealIds();
    final List<Meal> meals = [];

    for (final id in favoriteIds) {
      final mealJson = prefs.getString('meal_$id');
      if (mealJson != null) {
        final mealData = json.decode(mealJson);
        meals.add(Meal.fromJson(mealData));
      }
    }

    return meals;
  }

  // Clear all favorites
  Future<void> clearAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = await getFavoriteMealIds();

    for (final id in favoriteIds) {
      await prefs.remove('meal_$id');
    }

    await prefs.remove(_favoritesKey);
  }
}
