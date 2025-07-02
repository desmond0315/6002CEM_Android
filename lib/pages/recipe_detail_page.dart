import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> meal;

  const RecipeDetailPage({super.key, required this.meal});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  void _checkFavorite() async {
    bool fav = await FavoritesService().isFavorite(widget.meal['idMeal']);
    setState(() {
      isFavorite = fav;
    });
  }

  Future<void> _toggleFavorite() async {
    if (isFavorite) {
      await FavoritesService().removeFavorite(widget.meal['idMeal']);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Removed from favorites')),
      );
    } else {
      await FavoritesService().saveFavorite(widget.meal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('💖 Saved to favorites')),
      );
    }

    setState(() {
      isFavorite = !isFavorite;
    });
  }

  List<Map<String, String>> getIngredients() {
    List<Map<String, String>> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = widget.meal['strIngredient$i'];
      final measure = widget.meal['strMeasure$i'];

      if (ingredient != null &&
          ingredient.toString().isNotEmpty &&
          measure != null &&
          measure.toString().isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient.toString(),
          'measure': measure.toString(),
        });
      }
    }
    return ingredients;
  }


  @override
  Widget build(BuildContext context) {
    final ingredients = getIngredients();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal['strMeal'] ?? 'Recipe Detail'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.meal['strMealThumb'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(widget.meal['strMealThumb']),
              ),
            const SizedBox(height: 20),
            const Text("📝 Instructions",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              widget.meal['strInstructions'] ?? 'No instructions available',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("🧂 Ingredients",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...ingredients.map((item) => ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text('${item['ingredient']}'),
              trailing: Text(item['measure'] ?? ''),
            )),
          ],
        ),
      ),
    );
  }
}
