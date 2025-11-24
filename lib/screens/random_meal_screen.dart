import 'package:flutter/material.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';
import '../widgets/meal_detail_content.dart';

class RandomMealScreen extends StatefulWidget {
  const RandomMealScreen({Key? key}) : super(key: key);

  @override
  State<RandomMealScreen> createState() => _RandomMealScreenState();
}

class _RandomMealScreenState extends State<RandomMealScreen> {
  final ApiService _apiService = ApiService();
  MealDetail? _mealDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomMeal();
  }

  Future<void> _loadRandomMeal() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final detail = await _apiService.getRandomMeal();
      setState(() {
        _mealDetail = detail;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Recipe of the Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'New random recipe',
            onPressed: _loadRandomMeal,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mealDetail == null
              ? const Center(child: Text('Error loading'))
              : MealDetailContent(mealDetail: _mealDetail!),
    );
  }
}
