import 'package:flutter/material.dart';
import '../components/word_card.dart';
import '../components/section_card.dart';
import '../screens/chat_screen.dart';
import '../screens/practice_screen.dart';
import '../services/progress_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Keep up the great work with\nAstor-Academy!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // Handle search
                      },
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Recently Learned Words',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 240,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: const [
                        SizedBox(width: 24), // Initial padding
                        WordCard(
                          imagePath: 'assets/boy.jpg',
                          word: 'boy',
                        ),
                        SizedBox(width: 16), // Spacing between cards
                        WordCard(
                          imagePath: 'assets/man.jpg',
                          word: 'man',
                        ),
                        SizedBox(width: 16),
                        WordCard(
                          imagePath: 'assets/cat.jpg',
                          word: 'cat',
                        ),
                        SizedBox(width: 16),
                        WordCard(
                          imagePath: 'assets/boy.jpg',
                          word: 'girl',
                        ),
                        SizedBox(width: 16),
                        WordCard(
                          imagePath: 'assets/man.jpg',
                          word: 'woman',
                        ),
                        SizedBox(width: 16),
                        WordCard(
                          imagePath: 'assets/cat.jpg',
                          word: 'dog',
                        ),
                        SizedBox(width: 24), // Final padding
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SectionCard(
                  title: 'Practice',
                  subtitle: 'Learn to say \'I can see you\' in French',
                  imagePath: 'assets/practice.jpg',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PracticeScreen(),
                      ),
                    );
                  },
                ),
                SectionCard(
                  title: 'AI Chat',
                  subtitle: 'Chat with our AI to practice your language skills',
                  imagePath: 'assets/ai_chat.jpg',
                  onTap: () {
                    // Add ripple effect
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening AI Chat...'),
                        duration: Duration(milliseconds: 500),
                        backgroundColor: Color(0xFF2F6FED),
                      ),
                    );

                    // Navigate with fade transition
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const ChatScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
                SectionCard(
                  title: 'Games',
                  subtitle: 'Learn and play games at the same time',
                  imagePath: 'assets/games.jpg',
                  onTap: () {
                    // Handle games
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
