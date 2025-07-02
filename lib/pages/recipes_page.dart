import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_detail_page.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key}); // ✅ Const constructor

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> meals = [];
  bool isLoading = false;

  Future<void> fetchRecipes(String query) async {
    setState(() => isLoading = true);
    final url = Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=$query');

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      setState(() {
        meals = data['meals'] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching recipes: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecipes("chicken");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Recipes',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (searchController.text.trim().isNotEmpty) {
                    fetchRecipes(searchController.text.trim());
                  }
                },
                child: const Text('Search'),
              ),
            ],
          ),
        ),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (meals.isEmpty)
          const Expanded(child: Center(child: Text('No recipes found')))
        else
          Expanded(
            child: ListView.builder(
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Image.network(
                      meal['strMealThumb'],
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(meal['strMeal']),
                    subtitle: Text(
                      meal['strInstructions'].toString().substring(0, 50) + '...',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailPage(meal: meal),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
