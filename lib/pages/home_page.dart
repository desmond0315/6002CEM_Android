import 'package:flutter/material.dart';
import 'recipes_page.dart';
import 'favorites_page.dart';
import 'menu_page.dart';
import 'bmi_page.dart';
import 'bmi_history_page.dart';
import 'calorie_tracking_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 2; // Start at Home tab

  final List<Widget> pages = [
    const CalorieTrackingPage(),
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
  const HomeInfoPage({Key? key}) : super(key: key);

  String getUserDisplayName() {
    final email = FirebaseAuth.instance.currentUser?.email ?? "User";
    final namePart = email.split('@')[0];
    return namePart[0].toUpperCase() + namePart.substring(1);
  }

  String get todayDate => DateTime.now().toIso8601String().split('T').first;

  Stream<int> getTotalCalories(String collection) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection(collection)
        .where('date', isEqualTo: todayDate)
        .snapshots()
        .map((snapshot) => snapshot.docs.fold(
      0,
          (sum, doc) => sum + (doc['calories'] as int),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final userName = getUserDisplayName();

    return StreamBuilder<int>(
      stream: getTotalCalories('calorie_logs'),
      builder: (context, foodSnapshot) {
        return StreamBuilder<int>(
          stream: getTotalCalories('exercise_logs'),
          builder: (context, exerciseSnapshot) {
            final food = foodSnapshot.data ?? 0;
            final burned = exerciseSnapshot.data ?? 0;
            final net = food - burned;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 26, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        "Welcome, $userName",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your Daily Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Meals Logged
                  Card(
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.restaurant_menu, color: Colors.deepOrange),
                      title: const Text("Today's Meals"),
                      subtitle: Text("$food kcal consumed"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Exercise Logged
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.indigo),
                      title: const Text("Exercise Logged"),
                      subtitle: Text("$burned kcal burned"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Net Calories
                  Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: const Icon(Icons.local_fire_department, color: Colors.green),
                      title: const Text("Net Calories"),
                      subtitle: Text("$net kcal"),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BmiHistoryPage()),
                            );
                          },
                          icon: const Icon(Icons.history),
                          label: const Text("View BMI History"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FavoritesPage()),
                            );
                          },
                          icon: const Icon(Icons.favorite),
                          label: const Text("View Favorites"),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}



