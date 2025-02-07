import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class PracticeProgressOverview extends StatelessWidget {
  final ProgressService progressService;

  const PracticeProgressOverview({
    super.key,
    required this.progressService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2F6FED).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildProgressItem('Grammar'),
          _buildDivider(),
          _buildProgressItem('Vocabulary'),
          _buildDivider(),
          _buildProgressItem('Listening'),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String category) {
    final stats = progressService.getCategoryStats(category);
    final mastery = stats['mastery'] as double;
    final level = stats['level'] as int;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0, end: mastery),
              builder: (context, value, child) {
                return SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    value: value,
                    backgroundColor: const Color(0xFF2C2C2E),
                    valueColor: AlwaysStoppedAnimation(
                      _getColorForMastery(mastery),
                    ),
                    strokeWidth: 6,
                  ),
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Lvl $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(mastery * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          category,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          progressService.getMasteryTitle(category),
          style: TextStyle(
            color: _getColorForMastery(mastery),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: const Color(0xFF2C2C2E),
    );
  }

  Color _getColorForMastery(double mastery) {
    if (mastery >= 0.9) return const Color(0xFF4CAF50);
    if (mastery >= 0.7) return const Color(0xFF2F6FED);
    if (mastery >= 0.5) return const Color(0xFFFFA726);
    if (mastery >= 0.3) return const Color(0xFFFF7043);
    return const Color(0xFFE53935);
  }
}
