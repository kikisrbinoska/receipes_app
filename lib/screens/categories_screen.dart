import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import '../widgets/category_card.dart';
import 'meals_by_category_screen.dart';
import 'meal_detail_screen.dart';
import 'random_meal_screen.dart';
import 'favorites_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final ApiService _apiService = ApiService();
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _showDailyRecipeNotification();
  }

  Future<void> _showDailyRecipeNotification() async {
    // Wait a bit for the screen to load
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final notificationService = NotificationService();

    // Only show once per session
    if (notificationService.hasShownNotification) return;

    try {
      final meal = await notificationService.getTodaysMeal();

      if (!mounted) return;

      // Show Material Banner
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          padding: const EdgeInsets.all(16),
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.restaurant_menu, color: Colors.orange, size: 40),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Рецепт на денот! 🍽️',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meal.strMeal,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                notificationService.markNotificationAsShown();
              },
              child: const Text('ЗАТВОРИ'),
            ),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                notificationService.markNotificationAsShown();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MealDetailScreen(mealId: meal.idMeal),
                  ),
                );
              },
              child: const Text('ВИДИ'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Silently fail if notification can't be shown
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _apiService.getCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Грешка: $e')),
        );
      }
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _categories
            .where((category) =>
                category.strCategory.toLowerCase().contains(query.toLowerCase()) ||
                category.strCategoryDescription.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Категории на Рецепти'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Омилени рецепти',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Рандом рецепт',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RandomMealScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Пребарај категории...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCategories.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'Нема категории'
                              : 'Нема резултати за "$_searchQuery"',
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          return CategoryCard(
                            category: _filteredCategories[index],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MealsByCategoryScreen(
                                    category: _filteredCategories[index].strCategory,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}