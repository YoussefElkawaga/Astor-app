import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../widgets/progress_display.dart';
import 'package:provider/provider.dart';
import '../widgets/results_dialog.dart';

class VocabularyPracticeScreen extends StatefulWidget {
  const VocabularyPracticeScreen({super.key});

  @override
  State<VocabularyPracticeScreen> createState() =>
      _VocabularyPracticeScreenState();
}

class _VocabularyPracticeScreenState extends State<VocabularyPracticeScreen>
    with SingleTickerProviderStateMixin {
  // Modern color palette
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple
  static const Color accentColor = Color(0xFFEC4899); // Pink
  static const Color successColor = Color(0xFF22C55E); // Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color surfaceColor = Color(0xFF1E293B); // Slate
  static const Color backgroundColor = Color(0xFF0F172A); // Darker slate
  static const Color textColor = Color(0xFFF8FAFC); // Light gray

  int currentWord = 0;
  bool isAnswered = false;
  int selectedAnswer = -1;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  bool isAnimating = false;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  bool isQuizFinished = false;
  late final String category = 'vocabulary';
  int currentPoints = 0;
  int pointsPerCorrectAnswer = 20;
  double progressAnimation = 0.0;
  double masteryAnimation = 0.0;
  int totalQuestions = 10;
  late DateTime _startTime;

  final List<Map<String, dynamic>> words = [
    {
      'word': 'House',
      'meaning': 'A building for human habitation',
      'options': [
        'A type of vehicle',
        'A building for living',
        'A kind of food',
        'A piece of furniture'
      ],
      'correct': 1
    },
    {
      'word': 'Car',
      'meaning': 'A road vehicle powered by an engine',
      'options': [
        'A flying machine',
        'A water vessel',
        'A road vehicle',
        'A building'
      ],
      'correct': 2
    },
    {
      'word': 'Book',
      'meaning': 'A written or printed work',
      'options': [
        'A digital device',
        'A written work',
        'A type of food',
        'A piece of clothing'
      ],
      'correct': 1
    },
    {
      'word': 'Phone',
      'meaning': 'A device for communication',
      'options': [
        'A communication device',
        'A kitchen appliance',
        'A piece of furniture',
        'A type of food'
      ],
      'correct': 0
    },
    {
      'word': 'Computer',
      'meaning': 'An electronic device for processing data',
      'options': [
        'A musical instrument',
        'A cooking device',
        'An electronic device',
        'A type of vehicle'
      ],
      'correct': 2
    },
  ];

  final progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startTime = DateTime.now();
  }

  void _showFeedbackAnimation(bool isCorrect) {
    setState(() => isAnimating = true);

    if (!isCorrect) {
      _animationController
          .forward()
          .then((_) => _animationController.reverse());
    }

    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, _, child) {
        return Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.3 * animation.value),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: ScaleTransition(
                scale: CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                ),
                child: AlertDialog(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  content: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFE53935))
                              .withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 500),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Icon(
                                isCorrect
                                    ? Icons.check_circle_outline
                                    : Icons.close_rounded,
                                color: Colors.white,
                                size: 60,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isCorrect ? 'Correct!' : 'Incorrect',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isCorrect) ...[
                          const SizedBox(height: 8),
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: Text(
                                    'Correct meaning: ${words[currentWord]['meaning']}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      barrierDismissible: false,
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pop();
        setState(() => isAnimating = false);
      }
    });
  }

  Widget _buildProgressHeader() {
    return AnimatedBuilder(
      animation: progressService,
      builder: (context, child) {
        final stats = progressService.getCategoryStats(category);
        final progress = progressService.getCategoryProgress(category);

        // Calculate accuracy safely
        final totalAttempts = correctAnswers + wrongAnswers;
        final accuracy = totalAttempts > 0
            ? ((correctAnswers / totalAttempts) * 100).round()
            : 0;

        return TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          tween:
              Tween(begin: masteryAnimation, end: stats['mastery'] as double),
          builder: (context, mastery, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Level ${stats['level']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(progress * 100).round()}% to next',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween(begin: 0, end: stats['mastery'] as double),
                        builder: (context, value, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  value: value,
                                  backgroundColor: const Color(0xFF2C2C2E),
                                  valueColor: AlwaysStoppedAnimation(
                                    _getProgressColor(value),
                                  ),
                                  strokeWidth: 6,
                                ),
                              ),
                              Text(
                                '${(value * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Score',
                        '$correctAnswers/${words.length}',
                        Icons.check_circle_outline,
                        const Color(0xFF4CAF50),
                      ),
                      _buildStatItem(
                        'Points',
                        currentPoints.toString(),
                        Icons.stars,
                        const Color(0xFFFFA726),
                      ),
                      _buildStatItem(
                        'Accuracy',
                        '$accuracy%',
                        Icons.analytics,
                        const Color(0xFF2F6FED),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0, end: 1),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
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
          ),
        );
      },
    );
  }

  Color _getProgressColor(double mastery) {
    if (mastery >= 0.9) return const Color(0xFF4CAF50);
    if (mastery >= 0.7) return const Color(0xFF2F6FED);
    if (mastery >= 0.5) return const Color(0xFFFFA726);
    return const Color(0xFFE53935);
  }

  void _checkAnswer(int index) {
    if (isAnswered) return;

    final correctIndex = words[currentWord]['correct'] as int;
    setState(() {
      isAnswered = true;
      selectedAnswer = index;

      if (index == correctIndex) {
        correctAnswers++;
        final points = Provider.of<ProgressService>(context, listen: false)
            .calculatePoints(
          correctAnswers: correctAnswers,
          totalQuestions: words.length,
          streak: correctAnswers,
        );
        currentPoints += points;

        // Update progress immediately
        Provider.of<ProgressService>(context, listen: false)
            .updateCategoryProgress(
          category,
          correctAnswers: correctAnswers,
          totalQuestions: words.length,
          points: points,
          timeSpent: DateTime.now().difference(_startTime),
        );

        progressAnimation = (currentWord + 1) / words.length;
        masteryAnimation = correctAnswers / words.length;

        _showPointsGainAnimation(points);
        _showFeedbackAnimation(true);
      } else {
        wrongAnswers++;
        _showFeedbackAnimation(false);
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          if (currentWord < words.length - 1) {
            currentWord++;
            isAnswered = false;
            selectedAnswer = -1;
          } else {
            _showFinalResults();
          }
        });
      }
    });
  }

  void _showFinalResults() {
    final timeSpent = DateTime.now().difference(_startTime);
    final percentage = (correctAnswers / words.length * 100).round();
    final points = (percentage * 10).round();

    // Final update to progress
    Provider.of<ProgressService>(context, listen: false).updateCategoryProgress(
      category,
      correctAnswers: correctAnswers,
      totalQuestions: words.length,
      points: points,
      timeSpent: timeSpent,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultsDialog(
        correctAnswers: correctAnswers,
        totalQuestions: words.length,
        timeSpent: timeSpent,
        accuracy: percentage,
        points: points,
        onContinue: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showPointsGainAnimation(int points) {
    late final OverlayEntry overlay;

    overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.3,
        right: 24,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, -50 * value),
              child: Opacity(
                opacity: 1 - value,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 16),
                      Text(
                        '$points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onEnd: () => overlay.remove(),
        ),
      ),
    );

    Overlay.of(context).insert(overlay);
  }

  Widget _buildAnimatedButton(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween(begin: 1.0, end: isAnswered ? 0.95 : 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _getButtonColor(index).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _checkAnswer(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(index),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isAnswered ? 2 : 5,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          color: textColor.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      words[currentWord]['options'][index],
                      style: TextStyle(
                        color: textColor.withOpacity(isAnswered ? 0.9 : 1),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateProgress(BuildContext context) {
    final progressService =
        Provider.of<ProgressService>(context, listen: false);
    final points = progressService.calculatePoints(
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      streak: progressService.currentStreak,
    );

    progressService.updateCategoryProgress(
      category,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
      points: points,
      timeSpent: DateTime.now().difference(_startTime),
    );
  }

  Color _getButtonColor(int index) {
    if (!isAnswered) {
      return surfaceColor;
    }

    final correctIndex = words[currentWord]['correct'] as int;
    if (index == correctIndex) {
      return successColor.withOpacity(0.9);
    }
    if (index == selectedAnswer && selectedAnswer != correctIndex) {
      return errorColor.withOpacity(0.9);
    }
    return surfaceColor.withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book, color: textColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vocabulary Practice',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Question ${currentWord + 1} of ${words.length}',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<ProgressService>(
          builder: (context, progress, _) {
            return Column(
              children: [
                _buildProgressHeader(),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween(
                    begin: progressAnimation,
                    end: (currentWord + 1) / words.length,
                  ),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: const Color(0xFF2C2C2E),
                      valueColor:
                          AlwaysStoppedAnimation(_getProgressColor(value)),
                    );
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildWordDisplay(),
                          Column(
                            children: List.generate(
                              (words[currentWord]['options'] as List).length,
                              (index) => _buildAnimatedButton(index),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWordDisplay() {
    return Container(
      height: 200,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            words[currentWord]['word']!,
            style: const TextStyle(
              color: textColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Choose the correct meaning',
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
