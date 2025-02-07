import 'package:flutter/material.dart';

class CategoryFilter extends StatelessWidget {
  const CategoryFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
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
                  selected: false,
                  label: const Text('Grammar'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Vocabulary'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: true,
                  label: const Text('Conversation'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Reading'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Writing'),
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
