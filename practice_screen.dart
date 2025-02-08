import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grammar_practice_screen.dart';
import 'vocabulary_practice_screen.dart';
import '../services/progress_service.dart';
import '../widgets/points_summary.dart';
import '../widgets/practice_progress_overview.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF09090B),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.32,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF1C1C1E),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2F6FED), Color(0xFF1E4FC2)],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: MediaQuery.of(context).padding.top,
                              bottom: 24,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.22,
                                        ),
                                        child: PointsSummary(
                                          progressService: progressService,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Practice Categories with Live Updates
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: MediaQuery.of(context).size.height * 0.01,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Practice Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    _buildCategoryCard(
                      context: context,
                      title: 'Grammar',
                      subtitle: 'Master sentence structures and rules',
                      icon: Icons.rule,
                      color: const Color(0xFF2F6FED),
                      progress: progressService.getCategoryProgress('grammar'),
                      level: progressService.getLevelForCategory('grammar'),
                      points: progressService.categoryPoints['grammar'] ?? 0,
                      onTap: () => _navigateToExercise(
                        context,
                        const GrammarPracticeScreen(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    _buildCategoryCard(
                      context: context,
                      title: 'Vocabulary',
                      subtitle: 'Learn new words and phrases',
                      icon: Icons.book,
                      color: const Color(0xFF4CAF50),
                      progress:
                          progressService.getCategoryProgress('vocabulary'),
                      level: progressService.getLevelForCategory('vocabulary'),
                      points: progressService.categoryPoints['vocabulary'] ?? 0,
                      onTap: () => _navigateToExercise(
                        context,
                        const VocabularyPracticeScreen(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (progressService.getRecentAchievements().isNotEmpty)
                      _buildAchievementsSection(progressService),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToExercise(BuildContext context, Widget exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => exercise),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    required int level,
    required int points,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Material(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight * 0.15,
              maxHeight: screenHeight * 0.2,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(icon,
                                  color: color, size: screenWidth * 0.06),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      color: Colors.white60,
                                      fontSize: 14,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: TweenAnimationBuilder<int>(
                          duration: const Duration(milliseconds: 800),
                          tween: IntTween(begin: 0, end: points),
                          builder: (context, value, _) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$value pts',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                // Animated Progress Bar
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0, end: progress),
                  builder: (context, value, _) => Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4,
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation(color),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Level $level - ${(value * 100).round()}% to next',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
    ProgressService progressService,
  ) {
    final achievements = progressService.getRecentAchievements();
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Achievements',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: achievement['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: achievement['color'],
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      achievement['icon'],
                      color: achievement['color'],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      achievement['title'],
                      style: TextStyle(
                        color: achievement['color'],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
