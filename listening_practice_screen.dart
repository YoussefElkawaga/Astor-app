import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/progress_service.dart';
import '../services/eleven_labs_service.dart';
import 'package:just_audio/just_audio.dart';
import '../services/speech_service.dart';
import '../widgets/results_dialog.dart';
import 'dart:math';

class ListeningPracticeScreen extends StatefulWidget {
  const ListeningPracticeScreen({super.key});

  @override
  State<ListeningPracticeScreen> createState() =>
      _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;
  final TextEditingController _answerController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isAnswered = false;
  int currentWordIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  double progressAnimation = 0.0;
  double masteryAnimation = 0.0;
  late final String category = 'listening';
  int currentPoints = 0;
  int pointsPerCorrectAnswer = 20;
  bool isAnimating = false;
  late DateTime _startTime;

  // Modern color palette
  static const Color primaryColor = Color(0xFF2F6FED); // Blue
  static const Color secondaryColor = Color(0xFF4CAF50); // Green
  static const Color accentColor = Color(0xFFFFA726); // Orange
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color surfaceColor = Colors.white;
  static const Color backgroundColor = Color(0xFFF8F9FC); // Light gray
  static const Color textColor = Color(0xFF1A1F36); // Dark blue-gray

  final List<String> words = [
    'Elephant',
    'Beautiful',
    'Computer',
    'Adventure',
    'Chocolate',
    'Mountain',
    'Butterfly',
    'Orchestra',
    'Happiness',
    'Universe',
  ];

  late final SpeechService _speechService;
  bool isLoading = false;
  int hintsRemaining = 3;
  bool isVisualizing = false;
  List<double> audioVisualizerBars = List.generate(30, (index) => 0.0);

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _speechService = SpeechService();
    _speechService.initialize();
    _loadCurrentWord();
  }

  Future<void> _loadCurrentWord() async {
    setState(() => isLoading = true);
    try {
      await _speechService.speakWithElevenLabs(words[currentWordIndex]);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _playAudio() async {
    if (_speechService.isSpeaking) {
      await _speechService.stopSpeaking();
      setState(() => isVisualizing = false);
    } else {
      setState(() => isVisualizing = true);
      _updateAudioVisualization();
      await _speechService.speakWithElevenLabs(words[currentWordIndex]);
      setState(() => isVisualizing = false);
    }
    setState(() {});
  }

  void _updateAudioVisualization() {
    if (_speechService.isSpeaking) {
      setState(() {
        audioVisualizerBars = List.generate(
          30,
          (index) =>
              (0.1 + Random().nextDouble() * 0.9) *
              (_speechService.isSpeaking ? 1.0 : 0.1),
        );
      });
      Future.delayed(
          const Duration(milliseconds: 50), _updateAudioVisualization);
    } else {
      setState(() {
        audioVisualizerBars = List.generate(30, (index) => 0.1);
      });
    }
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
                    color: successColor,
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

  void _checkAnswer() {
    if (isAnswered) return;

    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = words[currentWordIndex].toLowerCase();

    setState(() {
      isAnswered = true;

      if (userAnswer == correctAnswer) {
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

        progressAnimation = (currentWordIndex + 1) / words.length;
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
          if (currentWordIndex < words.length - 1) {
            currentWordIndex++;
            isAnswered = false;
            _answerController.clear();
            _loadCurrentWord();
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

  void _showSuccessAnimation() {
    _showFeedbackAnimation(true);
  }

  void _showErrorAnimation() {
    _showFeedbackAnimation(false);
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
                      color: isCorrect ? successColor : errorColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isCorrect ? successColor : errorColor)
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
                                    'Correct word: ${words[currentWordIndex]}',
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

  void _useHint() {
    if (hintsRemaining > 0) {
      setState(() {
        hintsRemaining--;
        _answerController.text = words[currentWordIndex][0];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Hint: Word starts with "${words[currentWordIndex][0]}"'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
              child: const Icon(Icons.headphones, color: textColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Listening Practice',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Word ${currentWordIndex + 1} of ${words.length}',
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: const Color(0xFF4CAF50), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '$correctAnswers correct',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F6FED).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.stars,
                                color: const Color(0xFF2F6FED), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$currentPoints pts',
                              style: const TextStyle(
                                color: Color(0xFF2F6FED),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: progressAnimation,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF2F6FED)),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isVisualizing)
                            SizedBox(
                              height: 60,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  30,
                                  (index) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    width: 4,
                                    height: 60 * audioVisualizerBars[index],
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _speechService.isSpeaking
                                  ? primaryColor.withOpacity(0.1)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              iconSize: 64,
                              icon: Icon(
                                _speechService.isSpeaking
                                    ? Icons.pause_circle
                                    : Icons.play_circle_fill,
                                color: primaryColor,
                              ),
                              onPressed: _playAudio,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton.icon(
                            onPressed: hintsRemaining > 0 ? _useHint : null,
                            icon: Icon(Icons.lightbulb_outline,
                                color: hintsRemaining > 0
                                    ? accentColor
                                    : Colors.grey),
                            label: Text(
                              'Use Hint ($hintsRemaining remaining)',
                              style: TextStyle(
                                color: hintsRemaining > 0
                                    ? accentColor
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _answerController,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type what you hear...',
                          hintStyle: TextStyle(
                            color: textColor.withOpacity(0.5),
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                                color: primaryColor.withOpacity(0.1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide:
                                BorderSide(color: primaryColor, width: 2),
                          ),
                          suffixIcon: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor,
                                  primaryColor.withOpacity(0.8)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _checkAnswer,
                            ),
                          ),
                        ),
                        onSubmitted: (_) => _checkAnswer(),
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

  @override
  void dispose() {
    _speechService.dispose();
    _answerController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
