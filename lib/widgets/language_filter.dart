import 'package:flutter/material.dart';

class LanguageFilter extends StatelessWidget {
  const LanguageFilter({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Language',
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
                  label: const Text('English'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('Spanish'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('French'),
                  onSelected: (bool selected) {},
                ),
                FilterChip(
                  selected: false,
                  label: const Text('German'),
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
