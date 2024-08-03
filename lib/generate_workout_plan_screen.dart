import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';

class GenerateWorkoutPlanScreen extends StatefulWidget {
  const GenerateWorkoutPlanScreen({Key? key}) : super(key: key);

  @override
  _GenerateWorkoutPlanScreenState createState() =>
      _GenerateWorkoutPlanScreenState();
}

class _GenerateWorkoutPlanScreenState extends State<GenerateWorkoutPlanScreen> {
  String? _selectedGoal;
  String? _selectedExperience;
  bool _isLoading = false;
  String? _rawResponse;
  Map<String, dynamic>? _workoutPlan;

  final List<String> _fitnessGoals = [
    'Lose weight',
    'Build muscle',
    'Improve cardiovascular health',
    'Increase flexibility',
    'Enhance overall fitness'
  ];

  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Workout Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Select your fitness goal:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fitnessGoals
                  .map((goal) => ChoiceChip(
                        label: Text(goal),
                        selected: _selectedGoal == goal,
                        onSelected: (selected) {
                          setState(() {
                            _selectedGoal = selected ? goal : null;
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text('Select your experience level:',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _experienceLevels
                  .map((level) => ChoiceChip(
                        label: Text(level),
                        selected: _selectedExperience == level,
                        onSelected: (selected) {
                          setState(() {
                            _selectedExperience = selected ? level : null;
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (_selectedGoal != null &&
                      _selectedExperience != null &&
                      !_isLoading)
                  ? _generateWorkoutPlan
                  : null,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Generate Workout Plan'),
            ),
            const SizedBox(height: 24),
            if (_workoutPlan != null || _rawResponse != null)
              Expanded(
                child: SingleChildScrollView(
                  child: _buildWorkoutPlanDisplay(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutPlanDisplay() {
    if (_workoutPlan != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Personalized Workout Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 16),
          ..._workoutPlan!.entries
              .map((entry) => _buildSection(entry.key, entry.value)),
        ],
      );
    } else if (_rawResponse != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raw Response (Debug Info):',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 8),
          Text(_rawResponse!),
        ],
      );
    } else {
      return const Text('No workout plan generated yet.');
    }
  }

  Widget _buildSection(String title, dynamic content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (content is List)
              ...content.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(item.toString()),
                  ))
            else
              Text(content.toString()),
          ],
        ),
      ),
    );
  }

  Future<void> _generateWorkoutPlan() async {
    setState(() {
      _isLoading = true;
      _workoutPlan = null;
      _rawResponse = null;
    });

    final gemini = Gemini.instance;
    try {
      final response = await gemini.text(
          "Generate a structured workout plan for someone with the goal of $_selectedGoal and experience level: $_selectedExperience. "
          "The plan should include: 1. Warm-up exercises 2. Main workout routine 3. Cool-down exercises 4. Nutrition tips. "
          "Format the response as a JSON object with these keys: warmUp, mainWorkout, coolDown, nutritionTips. "
          "For exercises and tips, use an array of strings. "
          "Example format: "
          "{"
          "  \"warmUp\": [\"Exercise 1\", \"Exercise 2\"],"
          "  \"mainWorkout\": [\"Exercise 1\", \"Exercise 2\"],"
          "  \"coolDown\": [\"Exercise 1\", \"Exercise 2\"],"
          "  \"nutritionTips\": [\"Tip 1\", \"Tip 2\"]"
          "}");

      if (response?.output != null) {
        print("Raw Gemini response:");
        print(response!.output);
        setState(() {
          _rawResponse = response.output;
          _workoutPlan = _parseWorkoutPlan(response.output!);
          _isLoading = false;
        });
      } else {
        throw Exception('No output from Gemini');
      }
    } catch (e) {
      print('Error generating workout plan: $e');
      setState(() {
        _isLoading = false;
        _workoutPlan = null;
        _rawResponse = 'Error: $e';
      });
    }
  }

  Map<String, dynamic> _parseWorkoutPlan(String text) {
    // Remove any markdown formatting
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      // Replace problematic number ranges with strings
      text = text.replaceAllMapped(
          RegExp(r':\s*(\d+)-(\d+)([^\d]|$)'),
          (match) =>
              ': "${match.group(1)}-${match.group(2)}"${match.group(3)}');

      // Parse the JSON
      Map<String, dynamic> jsonResponse = jsonDecode(text);
      return _processJsonResponse(jsonResponse);
    } catch (e) {
      print('Error parsing JSON: $e');
      // If JSON parsing fails, fall back to text parsing
      return _parseWorkoutPlanText(text);
    }
  }

  Map<String, dynamic> _processJsonResponse(Map<String, dynamic> jsonResponse) {
    // Process each section of the workout plan
    ['warmUp', 'mainWorkout', 'coolDown', 'nutritionTips'].forEach((key) {
      if (jsonResponse[key] is List) {
        jsonResponse[key] = jsonResponse[key].map((item) {
          if (item is Map) {
            return item.entries.map((e) => "${e.key}: ${e.value}").join(', ');
          }
          return item.toString();
        }).toList();
      }
    });
    return jsonResponse;
  }

  Map<String, dynamic> _parseWorkoutPlanText(String text) {
    final Map<String, dynamic> plan = {};
    String currentSection = '';
    List<String> currentList = [];

    for (var line in text.split('\n')) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.endsWith(':')) {
        if (currentSection.isNotEmpty) {
          plan[currentSection] =
              currentList.isNotEmpty ? currentList : 'No details provided';
          currentList = [];
        }
        currentSection = line.substring(0, line.length - 1);
      } else {
        if (line.startsWith('•') || line.startsWith('-')) {
          currentList.add(line.substring(1).trim());
        } else {
          currentList.add(line);
        }
      }
    }

    if (currentSection.isNotEmpty) {
      plan[currentSection] =
          currentList.isNotEmpty ? currentList : 'No details provided';
    }

    return plan;
  }
}
