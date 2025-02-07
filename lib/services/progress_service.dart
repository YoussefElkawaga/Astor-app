import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProgressService extends ChangeNotifier {
  // Core stats
  int totalPoints = 0;
  int currentStreak = 0;
  DateTime? lastPracticeDate;

  // Category points
  Map<String, int> categoryPoints = {
    'grammar': 0,
    'vocabulary': 0,
    'listening': 0,
  };

  // Achievements and progress tracking
  Map<String, dynamic> achievements = {
    'stats': {
      'perfectScores': 0,
      'lessonsCompleted': 0,
      'dailyStreaks': 0,
      'totalPracticeTime': 0,
    },
    'mastery': {
      'grammar': 0.0,
      'vocabulary': 0.0,
      'listening': 0.0,
    },
    'progress': {
      'weeklyProgress': <int>[],
      'monthlyGoals': 0,
      'bestStreak': 0,
    },
    'rewards': {
      'trophies': 0,
      'badges': <String>[],
      'specialAwards': <String>[],
    },
  };

  // Achievement thresholds
  static const Map<String, Map<String, int>> _thresholds = {
    'streak': {'bronze': 7, 'silver': 30, 'gold': 100},
    'lessons': {'bronze': 50, 'silver': 200, 'gold': 500},
    'perfect': {'bronze': 10, 'silver': 50, 'gold': 100},
  };

  // Add these constants at the top of the class
  static const basePointsPerCorrectAnswer = 20;
  static const streakMultiplier = 0.2;
  static const accuracyMultiplier = 0.3;

  late SharedPreferences? _prefs;
  bool _isInitialized = false;

  // In-memory storage for web fallback
  final Map<String, dynamic> _webStorage = {};

  // Add these default values
  static final Map<String, int> defaultCategoryPoints = {
    'grammar': 0,
    'vocabulary': 0,
    'listening': 0,
  };

  static final Map<String, dynamic> defaultAchievements = {
    'stats': {
      'perfectScores': 0,
      'lessonsCompleted': 0,
      'dailyStreaks': 0,
      'totalPracticeTime': 0,
    },
    'mastery': {
      'grammar': 0.0,
      'vocabulary': 0.0,
      'listening': 0.0,
    },
    'progress': {
      'weeklyProgress': <int>[],
      'monthlyGoals': 0,
      'bestStreak': 0,
    },
    'rewards': {
      'trophies': 0,
      'badges': <String>[],
      'specialAwards': <String>[],
    },
  };

  Future<void> init() async {
    if (_isInitialized || kIsWeb) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _loadSavedData();
    } catch (e) {
      debugPrint('Storage initialization error: $e');
      _loadDefaultValues();
    }
    _isInitialized = true;
    notifyListeners();
  }

  void _loadDefaultValues() {
    totalPoints = 0;
    categoryPoints = {
      'grammar': 0,
      'vocabulary': 0,
      'listening': 0,
    };
    achievements = {
      'stats': {
        'perfectScores': 0,
        'lessonsCompleted': 0,
        'dailyStreaks': 0,
        'totalPracticeTime': 0,
      },
      'mastery': {
        'grammar': 0.0,
        'vocabulary': 0.0,
        'listening': 0.0,
      },
      'progress': {
        'weeklyProgress': <int>[],
        'monthlyGoals': 0,
        'bestStreak': 0,
      },
      'rewards': {
        'trophies': 0,
        'badges': <String>[],
        'specialAwards': <String>[],
      },
    };
  }

  void _loadSavedData() {
    if (kIsWeb) {
      _loadDefaultValues();
      return;
    }

    try {
      totalPoints = _prefs?.getInt('totalPoints') ?? 0;
      final savedCategoryPoints = _prefs?.getString('categoryPoints');
      if (savedCategoryPoints != null) {
        categoryPoints =
            Map<String, int>.from(json.decode(savedCategoryPoints));
      }
      final savedAchievements = _prefs?.getString('achievements');
      if (savedAchievements != null) {
        achievements = json.decode(savedAchievements);
      }
    } catch (e) {
      debugPrint('Error loading saved data: $e');
      _loadDefaultValues();
    }
    notifyListeners();
  }

  ProgressService() {
    // Initialize with defaults
    _loadDefaultValues();

    // Initialize SharedPreferences for non-web platforms
    if (!kIsWeb) {
      init();
    }
  }

  void addPoints(String category, int points) {
    totalPoints += points;
    categoryPoints[category] = (categoryPoints[category] ?? 0) + points;
    _updateMasteryLevel(category);
    _updateStreak();
    _updateWeeklyProgress(points);
    _checkAchievements();

    if (!kIsWeb) {
      _saveProgress();
    } else {
      _saveToWebStorage();
    }

    notifyListeners();
  }

  void _updateMasteryLevel(String category) {
    final points = categoryPoints[category] ?? 0;
    achievements['mastery'][category] = (points / 5000).clamp(0.0, 1.0);
  }

  void _updateStreak() {
    final now = DateTime.now();
    if (lastPracticeDate == null) {
      currentStreak = 1;
    } else {
      final difference = now.difference(lastPracticeDate!).inDays;
      if (difference == 1) {
        currentStreak++;
        if (currentStreak > (achievements['progress']['bestStreak'] ?? 0)) {
          achievements['progress']['bestStreak'] = currentStreak;
        }
      } else if (difference > 1) {
        currentStreak = 1;
      }
    }
    lastPracticeDate = now;
    achievements['stats']['dailyStreaks'] = currentStreak;
  }

  void _updateWeeklyProgress(int points) {
    List<int> weekProgress =
        List<int>.from(achievements['progress']['weeklyProgress'] ?? []);
    if (weekProgress.length >= 7) weekProgress.removeAt(0);
    weekProgress.add(points);
    achievements['progress']['weeklyProgress'] = weekProgress;
  }

  void _checkAchievements() {
    final stats = achievements['stats'];

    // Check and award streak achievements
    if (currentStreak >= _thresholds['streak']!['gold']!) {
      _awardBadge('Streak Master');
    } else if (currentStreak >= _thresholds['streak']!['silver']!) {
      _awardBadge('Streak Expert');
    } else if (currentStreak >= _thresholds['streak']!['bronze']!) {
      _awardBadge('Streak Starter');
    }

    // Check lesson completion achievements
    final lessonsCompleted = stats['lessonsCompleted'];
    if (lessonsCompleted >= _thresholds['lessons']!['gold']!) {
      _awardBadge('Learning Legend');
    }
  }

  void _awardBadge(String badge) {
    if (!achievements['rewards']['badges'].contains(badge)) {
      achievements['rewards']['badges'].add(badge);
      achievements['rewards']['trophies']++;
      notifyListeners();
    }
  }

  bool hasUnlockedAchievement(String achievement) {
    switch (achievement) {
      case 'perfectStreak':
        return currentStreak >= _thresholds['streak']!['bronze']!;
      case 'masterLearner':
        return (achievements['stats']['lessonsCompleted'] ?? 0) >=
            _thresholds['lessons']!['bronze']!;
      case 'perfectionist':
        return (achievements['stats']['perfectScores'] ?? 0) >=
            _thresholds['perfect']!['bronze']!;
      default:
        return false;
    }
  }

  int getLevelForCategory(String category) {
    final points = categoryPoints[category] ?? 0;
    return (points / 1000).floor() + 1;
  }

  String getMasteryTitle(String category) {
    final mastery = (achievements['mastery']?[category] ?? 0.0) as double;
    if (mastery >= 0.9) return 'Master';
    if (mastery >= 0.7) return 'Expert';
    if (mastery >= 0.5) return 'Advanced';
    if (mastery >= 0.3) return 'Intermediate';
    return 'Beginner';
  }

  double getProgressToNextLevel(String category) {
    final points = categoryPoints[category] ?? 0;
    return (points % 1000) / 1000;
  }

  List<Map<String, dynamic>> getRecentAchievements() {
    return [
      if (currentStreak >= 3)
        {
          'icon': Icons.local_fire_department,
          'title': '$currentStreak Day Streak!',
          'color': const Color(0xFFFFA726),
        },
      if ((achievements['stats']['perfectScores'] ?? 0) > 0)
        {
          'icon': Icons.stars,
          'title': 'Perfect Score!',
          'color': const Color(0xFF4CAF50),
        },
      if ((achievements['rewards']['trophies'] ?? 0) > 0)
        {
          'icon': Icons.emoji_events,
          'title': '${achievements['rewards']['trophies']} Trophies',
          'color': const Color(0xFF2F6FED),
        },
    ];
  }

  void updateProgress(String category, int score, int totalQuestions) {
    addPoints(category, score);

    // Update level progress
    final currentLevel = getLevelForCategory(category);
    final nextLevelThreshold = currentLevel * 1000;
    final progress = categoryPoints[category] ?? 0;

    // Check for level up
    if (progress >= nextLevelThreshold) {
      achievements['rewards']['badges'].add('$category Level $currentLevel');
      achievements['rewards']['trophies']++;
    }

    notifyListeners();
  }

  Map<String, dynamic> getCategoryStats(String category) {
    final mastery = (achievements['mastery']?[category] ?? 0.0) as double;
    return {
      'level': getLevelForCategory(category),
      'progress': getProgressToNextLevel(category),
      'mastery': mastery,
      'title': getMasteryTitle(category),
      'totalPoints': categoryPoints[category] ?? 0,
    };
  }

  void updateCategoryProgress(
    String category, {
    required int correctAnswers,
    required int totalQuestions,
    required int points,
  }) {
    // Update points
    addPoints(category, points);

    // Calculate and update mastery more aggressively
    final currentMastery =
        (achievements['mastery']?[category] ?? 0.0) as double;
    final accuracy = correctAnswers / totalQuestions;
    final masteryGain =
        accuracy * 0.3; // Increased from 0.2 for more visible progress
    achievements['mastery'][category] =
        (currentMastery + masteryGain).clamp(0.0, 1.0);

    // Update stats
    achievements['stats']['lessonsCompleted'] =
        (achievements['stats']['lessonsCompleted'] ?? 0) + 1;

    // Update level progress
    final currentLevel = getLevelForCategory(category);
    if (categoryPoints[category]! >= currentLevel * 1000) {
      achievements['rewards']['badges'].add('$category Level $currentLevel');
      achievements['rewards']['trophies']++;
    }

    notifyListeners();
  }

  double getCategoryProgress(String category) {
    final points = categoryPoints[category] ?? 0;
    final currentLevel = getLevelForCategory(category);
    final nextLevelPoints = currentLevel * 1000;
    return (points % 1000) / nextLevelPoints;
  }

  // Add this method
  int calculatePoints({
    required int correctAnswers,
    required int totalQuestions,
    required int streak,
  }) {
    final basePoints = basePointsPerCorrectAnswer;
    final streakBonus = (streak * streakMultiplier * basePoints).round();
    final accuracyBonus =
        ((correctAnswers / totalQuestions) * accuracyMultiplier * basePoints)
            .round();

    return basePoints + streakBonus + accuracyBonus;
  }

  void _saveToWebStorage() {
    _webStorage['totalPoints'] = totalPoints;
    _webStorage['categoryPoints'] = Map<String, dynamic>.from(categoryPoints);
    _webStorage['achievements'] = Map<String, dynamic>.from(achievements);
  }

  Future<void> _saveProgress() async {
    if (kIsWeb || _prefs == null) return;

    try {
      await _prefs!.setInt('totalPoints', totalPoints);
      await _prefs!.setString('categoryPoints', json.encode(categoryPoints));
      await _prefs!.setString('achievements', json.encode(achievements));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void initForWeb() {
    _loadDefaultValues();
    _isInitialized = true;
    notifyListeners();
  }
}
