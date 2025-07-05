import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> nutritionList = [];
  bool isLoading = false;

  final String appId = 'bb710b57';
  final String appKey = '10024f48d1274249f0b3ca459d2e1148';

  Future<void> fetchNutritionix(String food) async {
    setState(() {
      isLoading = true;
      nutritionList = [];
    });

    final url = Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients');

    try {
      final response = await http.post(
        url,
        headers: {
          'x-app-id': appId,
          'x-app-key': appKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'query': food}),
      );

      final data = json.decode(response.body);
      print("Nutritionix response: $data");

      if (response.statusCode == 200 && data['foods'] != null && data['foods'].isNotEmpty) {
        setState(() {
          nutritionList = List<Map<String, dynamic>>.from(data['foods']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Food not found. Try another input.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _nutrientLabel(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget buildCard(Map<String, dynamic> food) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              food['food_name'].toString().toUpperCase(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.scale, color: Colors.blue),
                const SizedBox(width: 6),
                Text("Serving: ${food['serving_qty']} ${food['serving_unit']}"),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.fitness_center, color: Colors.orange),
                const SizedBox(width: 6),
                Text("Weight: ${food['serving_weight_grams']} g"),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nutrientLabel(" Calories", "${food['nf_calories']} kcal"),
                _nutrientLabel(" Protein", "${food['nf_protein']} g"),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _nutrientLabel(" Fat", "${food['nf_total_fat']} g"),
                _nutrientLabel(" Carbs", "${food['nf_total_carbohydrate']} g"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: "Enter multiple foods (e.g. 1 apple, 2 eggs)",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final input = _controller.text.trim();
              if (input.isNotEmpty) {
                fetchNutritionix(input);
              }
            },
            child: const Text("Get Nutrition Info"),
          ),
          const SizedBox(height: 20),
          if (isLoading) const CircularProgressIndicator(),
          if (nutritionList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: nutritionList.length,
                itemBuilder: (context, index) {
                  return buildCard(nutritionList[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
