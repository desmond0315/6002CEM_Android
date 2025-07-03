import 'package:flutter/material.dart';
import 'dart:math';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({Key? key}) : super(key: key);

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  String _selectedGender = 'male';
  double? _bmi;
  String _bmiStatus = "";
  String _idealRange = "";

  Future<void> _calculateBMI() async {
    final weight = double.tryParse(weightController.text);
    final height = double.tryParse(heightController.text);
    final age = int.tryParse(ageController.text);

    if (weight == null || height == null || height == 0 || age == null) {
      setState(() {
        _bmi = null;
        _bmiStatus = "Please enter valid age, height and weight.";
        _idealRange = "";
      });
      return;
    }

    final bmi = weight / pow(height / 100, 2);
    double minKg = 18.5 * pow(height / 100, 2);
    double maxKg = 24.9 * pow(height / 100, 2);

    String status;
    if (_selectedGender == 'male') {
      if (bmi < 18.5) status = "Underweight";
      else if (bmi < 25) status = "Normal";
      else if (bmi < 30) status = "Overweight";
      else status = "Obese";
    } else {
      if (bmi < 18) status = "Underweight";
      else if (bmi < 24) status = "Normal";
      else if (bmi < 29) status = "Overweight";
      else status = "Obese";
    }

    setState(() {
      _bmi = double.parse(bmi.toStringAsFixed(1));
      _bmiStatus = status;
      _idealRange = "${minKg.toStringAsFixed(1)} – ${maxKg.toStringAsFixed(1)} kg";
    });

    // Save to Firebase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save user's email (if not already saved)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Save BMI record
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('bmi_history')
          .add({
        'age': age,
        'gender': _selectedGender,
        'height_cm': height,
        'weight_kg': weight,
        'bmi': _bmi,
        'status': _bmiStatus,
        'ideal_range': _idealRange,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Widget _categoryTable() {
    List<Map<String, dynamic>> categories = [
      {"label": "Very Severely Underweight", "range": "≤ 15.9", "min": 0.0, "max": 15.9},
      {"label": "Severely Underweight", "range": "16.0 – 16.9", "min": 16.0, "max": 16.9},
      {"label": "Underweight", "range": "17.0 – 18.4", "min": 17.0, "max": 18.4},
      {"label": "Normal", "range": "18.5 – 24.9", "min": 18.5, "max": 24.9},
      {"label": "Overweight", "range": "25.0 – 29.9", "min": 25.0, "max": 29.9},
      {"label": "Obese Class I", "range": "30.0 – 34.9", "min": 30.0, "max": 34.9},
      {"label": "Obese Class II", "range": "35.0 – 39.9", "min": 35.0, "max": 39.9},
      {"label": "Obese Class III", "range": "≥ 40.0", "min": 40.0, "max": 100},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("BMI Categories:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(1.2),
          },
          children: categories.map((cat) {
            final isActive = _bmi != null && _bmi! >= cat['min'] && _bmi! <= cat['max'];
            return TableRow(
              decoration: isActive
                  ? BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              )
                  : null,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    cat['label'],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.green : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    cat['range'],
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.green : Colors.black,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gender Selection
            const Text("Gender", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Row(children: [Icon(Icons.male), SizedBox(width: 4), Text("Male")]),
                  selected: _selectedGender == 'male',
                  onSelected: (_) => setState(() => _selectedGender = 'male'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Row(children: [Icon(Icons.female), SizedBox(width: 4), Text("Female")]),
                  selected: _selectedGender == 'female',
                  onSelected: (_) => setState(() => _selectedGender = 'female'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Age
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Height (cm)
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Height (cm)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Weight (kg)
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: _calculateBMI,
                child: const Text("Calculate BMI"),
              ),
            ),
            const SizedBox(height: 20),

            if (_bmi != null) ...[
              Center(
                child: SfRadialGauge(
                  axes: <RadialAxis>[
                    RadialAxis(
                      minimum: 10,
                      maximum: 45,
                      ranges: <GaugeRange>[
                        GaugeRange(startValue: 10, endValue: 18.5, color: Colors.blue),
                        GaugeRange(startValue: 18.5, endValue: 25, color: Colors.green),
                        GaugeRange(startValue: 25, endValue: 30, color: Colors.orange),
                        GaugeRange(startValue: 30, endValue: 45, color: Colors.red),
                      ],
                      pointers: <GaugePointer>[NeedlePointer(value: _bmi!)],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(
                          widget: Text('$_bmi', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          angle: 90,
                          positionFactor: 0.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Category: $_bmiStatus ($_selectedGender)",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text("Ideal Range: $_idealRange", style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              const SizedBox(height: 20),
              _categoryTable(),
            ],
          ],
        ),
      ),
    );
  }
}
