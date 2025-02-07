import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class PointsSummary extends StatelessWidget {
  final ProgressService progressService;

  const PointsSummary({
    super.key,
    required this.progressService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressService,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2F6FED), Color(0xFF1E4FC2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2F6FED).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedPoints(),
                      const SizedBox(height: 8),
                      Text(
                        'Current Streak: ${progressService.currentStreak} days',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  _buildStreakBadge(),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressBars(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedPoints() {
    return TweenAnimationBuilder<int>(
      duration: const Duration(milliseconds: 1500),
      tween: IntTween(begin: 0, end: progressService.totalPoints),
      builder: (context, value, _) {
        return Row(
          children: [
            const Icon(Icons.stars, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              '$value Points',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreakBadge() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.8, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.white, size: 32),
                if (progressService.currentStreak > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${progressService.currentStreak}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressBars() {
    return Column(
      children: [
        _buildCategoryProgress('Grammar', 'grammar'),
        const SizedBox(height: 8),
        _buildCategoryProgress('Vocabulary', 'vocabulary'),
        const SizedBox(height: 8),
        _buildCategoryProgress('Listening', 'listening'),
      ],
    );
  }

  Widget _buildCategoryProgress(String label, String category) {
    final stats = progressService.getCategoryStats(category);
    final progress = progressService.getCategoryProgress(category);

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0, end: progress),
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Level ${stats['level']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(Colors.white),
                minHeight: 6,
              ),
            ),
          ],
        );
      },
    );
  }
}
