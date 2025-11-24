import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/meal_detail.dart';

class MealDetailContent extends StatelessWidget {
  final MealDetail mealDetail;

  const MealDetailContent({
    Key? key,
    required this.mealDetail,
  }) : super(key: key);

  Future<void> _launchYouTube(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не може да се отвори YouTube')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Слика
          Image.network(
            mealDetail.strMealThumb,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.error, size: 50),
                ),
              );
            },
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Име на јадењето
                Text(
                  mealDetail.strMeal,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Категорија и регион
                Row(
                  children: [
                    Chip(
                      label: Text(mealDetail.strCategory),
                      backgroundColor: Colors.orange[100],
                      avatar: const Icon(Icons.restaurant, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(mealDetail.strArea),
                      backgroundColor: Colors.blue[100],
                      avatar: const Icon(Icons.public, size: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Состојки
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
                  itemCount: mealDetail.ingredients.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(
                        Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                      title: Text(mealDetail.ingredients[index]),
                      trailing: Text(
                        mealDetail.measures[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      dense: true,
                    );
                  },
                ),
                const SizedBox(height: 16),
                
                // Инструкции
                const Text(
                  'Инструкции:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mealDetail.strInstructions,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 16),
                
                // YouTube копче
                if (mealDetail.strYoutube.isNotEmpty)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchYouTube(context, mealDetail.strYoutube),
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
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}