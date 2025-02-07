import 'package:flutter/material.dart';
import '../services/progress_service.dart';
import '../widgets/progress_display.dart';

class GrammarPracticeScreen extends StatefulWidget {
  const GrammarPracticeScreen({super.key});

  @override
  State<GrammarPracticeScreen> createState() => _GrammarPracticeScreenState();
}

class _GrammarPracticeScreenState extends State<GrammarPracticeScreen>
    with SingleTickerProviderStateMixin {
  int currentQuestion = 0;
  bool isAnswered = false;
  int selectedAnswer = -1;
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  late Animation<double> _scaleAnimation;
  bool isAnimating = false;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  bool isQuizFinished = false;
  late final String category = 'grammar';
  int currentPoints = 0;
  int pointsPerCorrectAnswer = 20;
  double progressAnimation = 0.0;
  double masteryAnimation = 0.0;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Choose the correct form of the verb:',
      'sentence': 'She ___ to the store yesterday.',
      'options': ['go', 'goes', 'went', 'gone'],
      'correct': 2,
    },
    {
      'question': 'Select the correct tense:',
      'sentence': 'I ___ my homework right now.',
      'options': ['do', 'am doing', 'did', 'have done'],
      'correct': 1,
    },
    {
      'question': 'Pick the right preposition:',
      'sentence': 'The book is ___ the table.',
      'options': ['in', 'on', 'at', 'by'],
      'correct': 1,
    },
    {
      'question': 'Choose the correct article:',
      'sentence': 'I saw ___ elephant at the zoo.',
      'options': ['a', 'an', 'the', 'no article'],
      'correct': 1,
    },
    {
      'question': 'Select the right pronoun:',
      'sentence': '___ are going to the party tonight.',
      'options': ['We', 'Him', 'She', 'I'],
      'correct': 0,
    },
    {
      'question': 'Choose the correct modal verb:',
      'sentence': 'You ___ study hard to pass the exam.',
      'options': ['can', 'must', 'might', 'would'],
      'correct': 1,
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
  }

  Color _getButtonColor(int index) {
    if (!isAnswered) {
      return const Color(0xFF2C2C2E);
    }

    final correctIndex = questions[currentQuestion]['correct'] as int;
    if (index == correctIndex) {
      return const Color(0xFF4CAF50).withOpacity(0.8);
    }
    if (index == selectedAnswer && selectedAnswer != correctIndex) {
      return const Color(0xFFE53935).withOpacity(0.8);
    }
    return const Color(0xFF2C2C2E).withOpacity(0.5);
  }

  void _checkAnswer(int index) {
    if (isAnswered) return;

    final correctIndex = questions[currentQuestion]['correct'] as int;
    setState(() {
      isAnswered = true;
      selectedAnswer = index;

      if (index == correctIndex) {
        correctAnswers++;
        final points = progressService.calculatePoints(
          correctAnswers: correctAnswers,
          totalQuestions: questions.length,
          streak: correctAnswers,
        );
        currentPoints += points;

        progressAnimation = (currentQuestion + 1) / questions.length;
        masteryAnimation = correctAnswers / questions.length;

        progressService.updateCategoryProgress(
          category,
          correctAnswers: correctAnswers,
          totalQuestions: questions.length,
          points: points,
        );

        _showPointsGainAnimation(points);
        _showFeedbackAnimation(true);
      } else {
        wrongAnswers++;
        _showFeedbackAnimation(false);
      }
    });

    // Always move to next question after delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        if (currentQuestion < questions.length - 1) {
          setState(() {
            currentQuestion++;
            isAnswered = false;
            selectedAnswer = -1;
          });
        } else {
          _showFinalResults();
        }
      }
    });
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
                                    'Correct answer: ${questions[currentQuestion]['options'][questions[currentQuestion]['correct']]}',
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

  void _showFinalResults() {
    final percentage = (correctAnswers / questions.length * 100).round();
    final points = (percentage * 10).round();

    progressService.updateCategoryProgress(
      category,
      correctAnswers: correctAnswers,
      totalQuestions: questions.length,
      points: points,
    );

    progressService.achievements['stats']['perfectScores'] =
        (progressService.achievements['stats']['perfectScores'] ?? 0) +
            (percentage == 100 ? 1 : 0);
    progressService.achievements['stats']['lessonsCompleted'] =
        (progressService.achievements['stats']['lessonsCompleted'] ?? 0) + 1;

    showGeneralDialog(
      context: context,
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, _, child) {
        return Stack(
          children: [
            Container(
              color: Colors.black.withOpacity(0.5 * animation.value),
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: ScaleTransition(
                scale: animation,
                child: AlertDialog(
                  backgroundColor: const Color(0xFF1C1C1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  content: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOutBack,
                          tween: Tween(begin: 0, end: percentage.toDouble()),
                          builder: (context, value, child) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _getScoreColor(percentage),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${value.round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Text(
                                _getResultMessage(percentage),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Correct: $correctAnswers\nIncorrect: $wrongAnswers',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F6FED),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Finish',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      barrierDismissible: false,
    );
  }

  Color _getScoreColor(int percentage) {
    if (percentage >= 90) return const Color(0xFF4CAF50);
    if (percentage >= 70) return const Color(0xFF2F6FED);
    if (percentage >= 50) return const Color(0xFFFFA726);
    return const Color(0xFFE53935);
  }

  String _getResultMessage(int percentage) {
    if (percentage >= 90) return 'Excellent!';
    if (percentage >= 70) return 'Good Job!';
    if (percentage >= 50) return 'Keep Practicing!';
    return 'Try Again!';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Grammar Practice'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              tween: Tween(
                begin: progressAnimation,
                end: (currentQuestion + 1) / questions.length,
              ),
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: const Color(0xFF2C2C2E),
                  valueColor: AlwaysStoppedAnimation(_getProgressColor(value)),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1E),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2F6FED).withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              questions[currentQuestion]['question'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              questions[currentQuestion]['sentence'] as String,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            (questions[currentQuestion]['options'] as List)
                                .length,
                        itemBuilder: (context, index) =>
                            _buildAnimatedButton(index),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _checkAnswer(index),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(index),
                padding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: isAnswered ? 2 : 5,
              ),
              child: Text(
                questions[currentQuestion]['options'][index],
                style: TextStyle(
                  color: Colors.white.withOpacity(isAnswered ? 0.9 : 1),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
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
                      _buildMasteryIndicator(stats),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                        'Score',
                        '$correctAnswers/${questions.length}',
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

  Widget _buildMasteryIndicator(Map<String, dynamic> stats) {
    return Container(
      width: 60,
      height: 60,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: stats['mastery'] as double,
            backgroundColor: const Color(0xFF2C2C2E),
            valueColor: AlwaysStoppedAnimation(
              _getProgressColor(stats['mastery'] as double),
            ),
            strokeWidth: 6,
          ),
          Text(
            '${((stats['mastery'] as double) * 100).round()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double mastery) {
    if (mastery >= 0.9) return const Color(0xFF4CAF50);
    if (mastery >= 0.7) return const Color(0xFF2F6FED);
    if (mastery >= 0.5) return const Color(0xFFFFA726);
    return const Color(0xFFE53935);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
