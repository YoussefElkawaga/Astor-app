import 'package:flutter/material.dart';

class DifficultyFilter extends StatelessWidget {
  const DifficultyFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Difficulty Level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: true,
                  label: const Text('Beginner'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Intermediate'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Advanced'),
                  onSelected: (bool selected) {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
