import 'package:flutter/material.dart';

class ResultsDialog extends StatelessWidget {
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeSpent;
  final int accuracy;
  final int points;
  final VoidCallback onContinue;

  const ResultsDialog({
    super.key,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.timeSpent,
    required this.accuracy,
    required this.points,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1C1C1E),
      title: const Text(
        'Practice Complete!',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            'Score',
            '$correctAnswers/$totalQuestions',
            Icons.stars,
            const Color(0xFF2F6FED),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Accuracy',
            '$accuracy%',
            Icons.analytics,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Time',
            '${timeSpent.inMinutes}m ${timeSpent.inSeconds % 60}s',
            Icons.timer,
            const Color(0xFFFFA726),
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Points Earned',
            '+$points',
            Icons.emoji_events,
            const Color(0xFF9C27B0),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onContinue,
          child: const Text(
            'Continue',
            style: TextStyle(color: Color(0xFF2F6FED)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
