import 'package:flutter/material.dart';
import 'quick_workout_detail_screen.dart';

class QuickStartWorkout extends StatelessWidget {
  final List<Map<String, dynamic>> quickWorkouts = [
    {
      'name': 'Full Body HIIT',
      'duration': '20 min',
      'difficulty': 'Intermediate',
      'gifUrl':
          'https://j.gifs.com/oYBymz@large.gif?download=true', // Replace with actual GIF URL
      'description':
          'This High-Intensity Interval Training (HIIT) workout targets your entire body, helping you burn calories and improve cardiovascular fitness.',
      'exercises': [
        'Jumping jacks - 30 seconds',
        'Push-ups - 30 seconds',
        'Mountain climbers - 30 seconds',
        'Squat jumps - 30 seconds',
        'Burpees - 30 seconds',
        'Rest - 30 seconds',
        'Repeat circuit 3 times'
      ],
    },
    {
      'name': 'Core Crusher',
      'duration': '15 min',
      'difficulty': 'Beginner',
      'gifUrl':
          'https://example.com/core_crusher.gif', // Replace with actual GIF URL
      'description':
          'Strengthen your core with this quick and effective workout. Perfect for beginners looking to build a strong foundation.',
      'exercises': [
        'Plank hold - 30 seconds',
        'Crunches - 20 reps',
        'Russian twists - 30 seconds',
        'Leg raises - 15 reps',
        'Superman hold - 30 seconds',
        'Rest - 30 seconds',
        'Repeat circuit 2 times'
      ],
    },
    {
      'name': 'Upper Body Strength',
      'duration': '30 min',
      'difficulty': 'Advanced',
      'gifUrl':
          'https://example.com/upper_body_strength.gif', // Replace with actual GIF URL
      'description':
          'Challenge your upper body with this comprehensive strength workout. Suitable for those with some fitness experience looking to build muscle and strength.',
      'exercises': [
        'Push-ups - 15 reps',
        'Dumbbell rows - 12 reps each arm',
        'Overhead press - 10 reps',
        'Tricep dips - 12 reps',
        'Bicep curls - 12 reps',
        'Rest - 60 seconds',
        'Repeat circuit 3 times'
      ],
    },
  ];

  QuickStartWorkout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Start',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Need a quick workout? Try our pre-made plans!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: () => _showQuickWorkoutOptions(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor: Colors.white,
              ),
              child: const Text('Start Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickWorkoutOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a Quick Workout',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...quickWorkouts
                  .map((workout) => _buildWorkoutTile(context, workout))
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutTile(BuildContext context, Map<String, dynamic> workout) {
    return ListTile(
      title: Text(workout['name']),
      subtitle: Text('${workout['duration']} • ${workout['difficulty']}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _startQuickWorkout(context, workout),
    );
  }

  void _startQuickWorkout(BuildContext context, Map<String, dynamic> workout) {
    Navigator.pop(context); // Close the bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuickWorkoutDetailScreen(
          workoutName: workout['name'],
          gifUrl: workout['gifUrl'],
          description: workout['description'],
          exercises: List<String>.from(workout['exercises']),
          duration: workout['duration'],
          difficulty: workout['difficulty'],
        ),
      ),
    );
  }
}
