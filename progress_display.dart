import 'package:flutter/material.dart';
import '../services/progress_service.dart';

class ProgressDisplay extends StatelessWidget {
  final ProgressService progressService;

  const ProgressDisplay({
    super.key,
    required this.progressService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F6FED).withOpacity(0.2),
            blurRadius: 20,
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
                  Text(
                    'Total Points',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<int>(
                    duration: const Duration(seconds: 1),
                    tween: IntTween(
                      begin: 0,
                      end: progressService.totalPoints,
                    ),
                    builder: (context, value, child) {
                      return Text(
                        value.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F6FED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCategoryProgress(
                  'Grammar', progressService.categoryPoints['grammar'] ?? 0),
              _buildCategoryProgress('Vocabulary',
                  progressService.categoryPoints['vocabulary'] ?? 0),
              _buildCategoryProgress('Listening',
                  progressService.categoryPoints['listening'] ?? 0),
            ],
          ),
          if ((progressService.achievements['lastWeekProgress'] as List?)
                  ?.isNotEmpty ??
              false)
            const SizedBox(height: 24),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  (progressService.achievements['lastWeekProgress'] as List?)
                          ?.length ??
                      0,
              itemBuilder: (context, index) {
                final points = (progressService.achievements['lastWeekProgress']
                        as List?)?[index] ??
                    0;
                return Container(
                  width: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1000),
                          tween: Tween(begin: 0, end: points / 100),
                          builder: (context, value, child) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF2F6FED),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              height: value * 80,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 1}d',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAchievementBadge(
                '7-Day Streak',
                'Practice every day',
                progressService.hasUnlockedAchievement('perfectStreak'),
              ),
              _buildAchievementBadge(
                'Master Learner',
                '50 lessons completed',
                progressService.hasUnlockedAchievement('masterLearner'),
              ),
              _buildAchievementBadge(
                'Perfectionist',
                '10 perfect scores',
                progressService.hasUnlockedAchievement('perfectionist'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgress(String category, int points) {
    final level = progressService.getLevelForCategory(category);
    final progress = (points % 1000) / 1000;

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0, end: progress),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0xFF2C2C2E),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2F6FED)),
                  strokeWidth: 8,
                );
              },
            ),
            Text(
              'Lvl $level',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          category,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(
      String title, String description, bool isUnlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? const Color(0xFF2F6FED) : const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: const Color(0xFF2F6FED).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          Icon(
            isUnlocked ? Icons.emoji_events : Icons.lock_outline,
            color: isUnlocked ? Colors.white : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white38,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: TextStyle(
              color: isUnlocked ? Colors.white70 : Colors.white24,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
