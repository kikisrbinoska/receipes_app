import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';
import '../services/api_service.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({Key? key, required this.mealId}) : super(key: key);

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final ApiService _apiService = ApiService();
  MealDetail? _mealDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMealDetail();
  }

  Future<void> _loadMealDetail() async {
    try {
      final detail = await _apiService.getMealDetail(widget.mealId);
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

  Future<void> _launchYouTube(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не може да се отвори YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_mealDetail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Јадењето не е пронајдено')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_mealDetail!.strMeal),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _mealDetail!.strMealThumb,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mealDetail!.strMeal,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Chip(
                        label: Text(_mealDetail!.strCategory),
                        backgroundColor: Colors.orange[100],
                      ),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(_mealDetail!.strArea),
                        backgroundColor: Colors.blue[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Состојки:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mealDetail!.ingredients.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(_mealDetail!.ingredients[index]),
                        trailing: Text(_mealDetail!.measures[index]),
                        dense: true,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Инструкции:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _mealDetail!.strInstructions,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  if (_mealDetail!.strYoutube.isNotEmpty)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => _launchYouTube(_mealDetail!.strYoutube),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Гледај на YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}