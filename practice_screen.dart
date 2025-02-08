import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'grammar_practice_screen.dart';
import 'vocabulary_practice_screen.dart';
import 'listening_practice_screen.dart';
import '../services/progress_service.dart';
import '../widgets/points_summary.dart';
import '../widgets/practice_progress_overview.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressService>(
      builder: (context, progressService, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FC),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.35,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF2F6FED),
                              const Color(0xFF1E88E5).withOpacity(0.9),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Your Progress',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildPointsSummary(
                                        context, progressService),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            _buildCategoryProgress(
                                              context,
                                              progressService,
                                              'vocabulary',
                                              const Color(0xFF4CAF50),
                                              constraints.maxWidth,
                                            ),
                                            _buildCategoryProgress(
                                              context,
                                              progressService,
                                              'grammar',
                                              const Color(0xFF2F6FED),
                                              constraints.maxWidth,
                                            ),
                                            _buildCategoryProgress(
                                              context,
                                              progressService,
                                              'listening',
                                              const Color(0xFFFFA726),
                                              constraints.maxWidth,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const Text(
                      'Practice Categories',
                      style: TextStyle(
                        color: Color(0xFF1A1F36),
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
                    _buildCategoryCard(
                      context: context,
                      title: 'Listening',
                      subtitle: 'Practice your listening skills',
                      icon: Icons.headphones,
                      color: const Color(0xFF9C27B0),
                      progress:
                          progressService.getCategoryProgress('listening'),
                      level: progressService.getLevelForCategory('listening'),
                      points: progressService.categoryPoints['listening'] ?? 0,
                      onTap: () => _navigateToExercise(
                        context,
                        const ListeningPracticeScreen(),
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
    return Hero(
      tag: 'category_$title',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1A1F36),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildProgressIndicator(progress, color),
                    _buildPointsBadge(points, color),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(double progress, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(value * 100).round()}% Complete',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsBadge(int points, Color color) {
    return Padding(
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

  Widget _buildPointsSummary(
      BuildContext context, ProgressService progressService) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPointsItem(
            'Total Points',
            '${progressService.totalPoints}',
            Icons.stars_rounded,
          ),
          _buildDivider(),
          _buildPointsItem(
            'Streak',
            '${progressService.currentStreak} days',
            Icons.local_fire_department_rounded,
          ),
          _buildDivider(),
          _buildPointsItem(
            'Level',
            '${_calculateOverallLevel(progressService)}',
            Icons.trending_up_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }

  int _calculateOverallLevel(ProgressService progressService) {
    final grammarLevel = progressService.getLevelForCategory('grammar');
    final vocabularyLevel = progressService.getLevelForCategory('vocabulary');
    final listeningLevel = progressService.getLevelForCategory('listening');
    return ((grammarLevel + vocabularyLevel + listeningLevel) / 3).ceil();
  }

  Widget _buildCategoryProgress(
    BuildContext context,
    ProgressService progressService,
    String category,
    Color color,
    double maxWidth,
  ) {
    final stats = progressService.getCategoryStats(category);
    final progress = progressService.getCategoryProgress(category);
    final level = stats['level'] as int;
    final points = progressService.categoryPoints[category] ?? 0;
    final mastery = stats['mastery'] as double;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    color: color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.capitalize(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level $level',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: 0, end: mastery),
                builder: (context, value, _) {
                  return Container(
                    height: 8,
                    width: maxWidth * value,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$points points',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
              Text(
                '${(mastery * 100).round()}% Mastery',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'grammar':
        return Icons.rule_rounded;
      case 'vocabulary':
        return Icons.book_rounded;
      case 'listening':
        return Icons.headphones_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
