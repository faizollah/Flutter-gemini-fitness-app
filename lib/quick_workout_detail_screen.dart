import 'package:flutter/material.dart';

class QuickWorkoutDetailScreen extends StatelessWidget {
  final String workoutName;
  final String gifUrl;
  final String description;
  final List<String> exercises;
  final String duration;
  final String difficulty;

  const QuickWorkoutDetailScreen({
    Key? key,
    required this.workoutName,
    required this.gifUrl,
    required this.description,
    required this.exercises,
    required this.duration,
    required this.difficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workoutName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GIF
            Image.network(
              gifUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workout details
                  Text(
                    'Duration: $duration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Difficulty: $difficulty',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                  const SizedBox(height: 16),
                  // Exercises
                  Text(
                    'Exercises',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...exercises
                      .map((exercise) => Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text('• $exercise'),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
