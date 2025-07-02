import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalorieTrackingPage extends StatefulWidget {
  const CalorieTrackingPage({Key? key}) : super(key: key);

  @override
  _CalorieTrackingPageState createState() => _CalorieTrackingPageState();
}

class _CalorieTrackingPageState extends State<CalorieTrackingPage> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();
  final TextEditingController _burnedCalorieController = TextEditingController();
  int _dailyGoal = 1800;

  String _selectedMealType = 'Breakfast';

  @override
  void initState() {
    super.initState();
    _loadCalorieGoal();
  }

  Future<void> _loadCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('dailyGoal') ?? 1800;
    });
  }

  Future<void> _updateCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final TextEditingController controller = TextEditingController(text: _dailyGoal.toString());

    final newGoal = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Calorie Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Calories (e.g. 2000)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newGoal != null) {
      await prefs.setInt('dailyGoal', newGoal);
      setState(() => _dailyGoal = newGoal);
    }
  }

  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> _addMeal() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _foodController.text.isEmpty || _calorieController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calorie_logs')
        .add({
      'food': _foodController.text,
      'calories': int.parse(_calorieController.text),
      'mealType': _selectedMealType,
      'timestamp': Timestamp.now(),
      'date': todayDate,
    });

    _foodController.clear();
    _calorieController.clear();
  }

  Future<void> _addExercise() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _exerciseController.text.isEmpty || _burnedCalorieController.text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('exercise_logs')
        .add({
      'exercise': _exerciseController.text,
      'calories': int.parse(_burnedCalorieController.text),
      'timestamp': Timestamp.now(),
      'date': todayDate,
    });

    _exerciseController.clear();
    _burnedCalorieController.clear();
  }

  Future<void> _confirmDelete({
    required String docId,
    required String collectionName,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(collectionName)
          .doc(docId)
          .delete();
    }
  }

  Stream<QuerySnapshot> _getTodayMeals() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('calorie_logs')
        .where('date', isEqualTo: todayDate)
        .snapshots();
  }

  Stream<QuerySnapshot> _getTodayExercises() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('exercise_logs')
        .where('date', isEqualTo: todayDate)
        .snapshots();
  }

  int _sumCalories(List<DocumentSnapshot> docs) {
    return docs.fold(0, (sum, doc) => sum + (doc['calories'] as int));
  }

  Widget _buildInputCard({
    required String title,
    required List<Widget> children,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onDelete,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.2),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.redAccent),
        onPressed: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _getTodayMeals(),
              builder: (context, mealSnapshot) {
                return StreamBuilder<QuerySnapshot>(
                  stream: _getTodayExercises(),
                  builder: (context, exerciseSnapshot) {
                    if (!mealSnapshot.hasData || !exerciseSnapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    final foodDocs = mealSnapshot.data!.docs;
                    final exerciseDocs = exerciseSnapshot.data!.docs;
                    final foodTotal = _sumCalories(foodDocs);
                    final burnedTotal = _sumCalories(exerciseDocs);
                    final netTotal = foodTotal - burnedTotal;

                    final double progress = (netTotal / _dailyGoal).clamp(0.0, 1.0);
                    final Color progressColor = netTotal >= _dailyGoal ? Colors.red : Colors.green;

                    return GestureDetector(
                      onTap: _updateCalorieGoal,
                      child: Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Today's Progress",
                                  style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: progress,
                                color: progressColor,
                                backgroundColor: Colors.grey[300],
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "$netTotal / $_dailyGoal kcal",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Meal + Exercise Input Sections (unchanged)
            _buildInputCard(
              title: "Log Meal",
              color: Colors.green,
              children: [
                TextField(
                  controller: _foodController,
                  decoration: const InputDecoration(labelText: 'Food Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _calorieController,
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedMealType,
                  isExpanded: true,
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedMealType = value);
                  },
                  items: const [
                    DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'Snack', child: Text('Snack')),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addMeal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  child: const Text('Add Meal'),
                ),
              ],
            ),

            _buildInputCard(
              title: "Log Exercise",
              color: Colors.orange,
              children: [
                TextField(
                  controller: _exerciseController,
                  decoration: const InputDecoration(labelText: 'Exercise Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _burnedCalorieController,
                  decoration: const InputDecoration(labelText: 'Calories Burned'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addExercise,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  child: const Text('Add Exercise'),
                ),
              ],
            ),

            StreamBuilder<QuerySnapshot>(
              stream: _getTodayMeals(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final docs = snapshot.data!.docs;
                return _buildInputCard(
                  title: "Meals Logged",
                  color: Colors.black87,
                  children: docs
                      .map((doc) => _buildTile(
                    title: doc['food'],
                    subtitle: '${doc['mealType']} - ${doc['calories']} kcal',
                    icon: Icons.restaurant,
                    color: Colors.green,
                    onDelete: () => _confirmDelete(
                      docId: doc.id,
                      collectionName: 'calorie_logs',
                    ),
                  ))
                      .toList(),
                );
              },
            ),

            StreamBuilder<QuerySnapshot>(
              stream: _getTodayExercises(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final docs = snapshot.data!.docs;
                return _buildInputCard(
                  title: "Exercises Logged",
                  color: Colors.black87,
                  children: docs
                      .map((doc) => _buildTile(
                    title: doc['exercise'],
                    subtitle: '${doc['calories']} kcal burned',
                    icon: Icons.directions_run,
                    color: Colors.orange,
                    onDelete: () => _confirmDelete(
                      docId: doc.id,
                      collectionName: 'exercise_logs',
                    ),
                  ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
