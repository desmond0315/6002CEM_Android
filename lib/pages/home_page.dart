import 'package:flutter/material.dart';
import 'recipes_page.dart';
import 'favorites_page.dart';
import 'menu_page.dart';
import 'bmi_page.dart';
import 'bmi_history_page.dart';
import 'calorie_tracking_page.dart'; // ✅ Import the real Calorie Tracker page

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2; // Start at Home tab

  final List<Widget> pages = [
    const CalorieTrackingPage(), // ✅ Replace TrackerPage with real one
    const MenuPage(),
    const HomeInfoPage(),
    const RecipesPage(),
    const BmiPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[currentIndex],
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.restaurant),
                color: currentIndex == 0 ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => currentIndex = 0),
              ),
              IconButton(
                icon: const Icon(Icons.menu_book),
                color: currentIndex == 1 ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => currentIndex = 1),
              ),
              GestureDetector(
                onTap: () => setState(() => currentIndex = 2),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.home,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.book),
                color: currentIndex == 3 ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => currentIndex = 3),
              ),
              IconButton(
                icon: const Icon(Icons.fitness_center),
                color: currentIndex == 4 ? Colors.blue : Colors.grey,
                onPressed: () => setState(() => currentIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// Home Info Page (unchanged)
//

class HomeInfoPage extends StatelessWidget {
  const HomeInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "🏠 Home Page\n(Coming Soon)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesPage()),
                );
              },
              icon: const Icon(Icons.favorite),
              label: const Text('View Favorite Recipes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BmiHistoryPage()),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View BMI History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
