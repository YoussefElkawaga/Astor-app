import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/api_config.dart';
import '../services/speech_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model;
  late ChatSession _chat;
  bool _isTyping = false;
  final SpeechService _speechService = SpeechService();
  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  Timer? silenceTimer;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _speechService.initialize();
  }

  void _initializeChat() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: ApiConfig.apiKey,
    );
    _chat = _model.startChat();

    setState(() {
      _messages.add(
        ChatMessage(
          text:
              "Hello! I'm your AI language tutor. How can I help you learn today?",
          isUser: false,
          senderName: "Astor",
        ),
      );
    });
  }

  Future<void> _handleVoiceInput() async {
    await _speechService.forceStopAudio();
    setState(() => _isProcessing = false);

    if (_isListening) {
      await _speechService.stop();
      setState(() {
        _isListening = false;
        _isProcessing = false;
        // Remove temporary message if it exists
        if (_messages.isNotEmpty && _messages.last.text == "جاري الاستماع...") {
          _messages.removeLast();
        }
      });
      return;
    }

    // Start new recording
    setState(() {
      _isListening = true;
      _recognizedText = '';
      _messages.add(ChatMessage(
        text: "جاري الاستماع...",
        isUser: true,
        senderName: "You",
        isVoiceMessage: true,
      ));
    });
    _scrollToBottom();

    try {
      String lastRecognizedText = '';
      await _speechService.listen(
        onTextRecognized: (text) async {
          if (!_isProcessing && text.isNotEmpty) {
            // Update message in real-time
            setState(() {
              _messages.last = ChatMessage(
                text: text,
                isUser: true,
                senderName: "You",
                isVoiceMessage: true,
              );
            });
            _scrollToBottom();

            lastRecognizedText = text;
            silenceTimer?.cancel();
            silenceTimer = Timer(const Duration(seconds: 3), () async {
              if (!_isProcessing && lastRecognizedText.isNotEmpty) {
                _isProcessing = true;
                await _speechService.stop();

                // Add AI typing indicator
                setState(() {
                  _messages.add(ChatMessage(
                    text: "",
                    isUser: false,
                    senderName: "Astor",
                    isVoiceMessage: true,
                    isTyping: true,
                  ));
                });
                _scrollToBottom();

                try {
                  final prompt = '''أنت مساعد ذكي في برنامج لتعليم اللغات. 
يجب أن تكون ردودك واضحة ومباشرة وبدون أي رموز خاصة أو علامات نجمية.
رد على هذه الرسالة: $lastRecognizedText''';

                  final response =
                      await _chat.sendMessage(Content.text(prompt));

                  if (response.text != null) {
                    final aiMessage = response.text!
                        .replaceAll('*', '')
                        .replaceAll('_', '')
                        .replaceAll('#', '')
                        .trim();

                    setState(() {
                      if (_messages.last.isTyping) {
                        _messages.removeLast();
                      }

                      _messages.add(ChatMessage(
                        text: aiMessage,
                        isUser: false,
                        senderName: "Astor",
                        isVoiceMessage: true,
                      ));
                      _isProcessing = false;
                      _isListening = false;
                    });
                    _scrollToBottom();

                    if (!_speechService.isSpeaking) {
                      await _speechService.speakWithElevenLabs(aiMessage);
                    }
                  }
                } catch (e) {
                  print('Error: $e');
                  setState(() {
                    _isProcessing = false;
                    _isListening = false;
                    if (_messages.last.isTyping) {
                      _messages.removeLast();
                    }
                    _messages.add(ChatMessage(
                      text: "عذراً، حدث خطأ. حاول مرة أخرى.",
                      isUser: false,
                      senderName: "Astor",
                      isVoiceMessage: true,
                    ));
                  });
                  _scrollToBottom();
                }
              }
            });
          }
        },
      );
    } catch (e) {
      print('Voice input error: $e');
      setState(() {
        _isListening = false;
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = text;
    _messageController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        senderName: "You",
      ));
      // Add typing indicator for AI
      _messages.add(ChatMessage(
        text: "",
        isUser: false,
        senderName: "Astor",
        isTyping: true,
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    try {
      setState(() => _isProcessing = true);

      final response = await _chat.sendMessage(Content.text(userMessage));
      final aiMessage = response.text ?? 'Sorry, I couldn\'t understand that.';

      setState(() {
        _isTyping = false;
        _isProcessing = false;
        // Remove typing indicator
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: aiMessage,
          isUser: false,
          senderName: "Astor",
        ));
      });

      _scrollToBottom();
      if (!_speechService.isSpeaking) {
        await _speechService.speakWithElevenLabs(aiMessage);
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _isProcessing = false;
        // Remove typing indicator
        _messages.removeLast();
        _messages.add(ChatMessage(
          text: "An error occurred. Please try again.",
          isUser: false,
          senderName: "Astor",
        ));
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        color: _isProcessing ? Colors.grey : const Color(0xFF2F6FED),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.send, color: Colors.white),
        onPressed: _isProcessing
            ? null
            : () => _handleSubmitted(_messageController.text),
      ),
    );
  }

  Widget _buildVoiceControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () async {
            if (_speechService.isSpeaking) {
              // Stop speaking
              await _speechService.forceStopAudio();
              setState(() => _isProcessing = false);
            } else {
              // Start/stop recording
              await _handleVoiceInput();
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _speechService.isSpeaking || _isListening
                  ? Colors.red.withOpacity(0.2)
                  : Colors.blue.withOpacity(0.1),
            ),
            child: Icon(
              _speechService.isSpeaking
                  ? Icons.stop_circle
                  : _isListening
                      ? Icons.mic
                      : Icons.mic_none,
              color: _speechService.isSpeaking
                  ? Colors.red
                  : _isListening || _isProcessing
                      ? const Color(0xFF2F6FED)
                      : Colors.white70,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Astor AI Tutor',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              'Language Learning Assistant',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF1C1C1E),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TopicChip(
                    label: 'Travel',
                    isSelected: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: 'Food',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: 'Work',
                    isSelected: false,
                    onTap: () {},
                  ),
                  const SizedBox(width: 8),
                  _TopicChip(
                    label: 'Hobbies',
                    isSelected: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + 1,
              itemBuilder: (context, index) {
                if (index < _messages.length) {
                  return _messages[index];
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            enabled: !_isProcessing,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText:
                                  'Type your message or press the mic to speak...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            onSubmitted:
                                _isProcessing ? null : _handleSubmitted,
                          ),
                        ),
                        _buildVoiceControls(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildSendButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _speechService.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final String senderName;
  final bool isVoiceMessage;
  final bool isTyping;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    required this.senderName,
    this.isVoiceMessage = false,
    this.isTyping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                senderName,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              if (isVoiceMessage) ...[
                const SizedBox(width: 8),
                Icon(
                  isUser ? Icons.mic : Icons.volume_up,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF2F6FED) : const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
              border: isVoiceMessage
                  ? Border.all(
                      color: const Color(0xFF2F6FED).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: isTyping
                ? const TypingIndicator()
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopicChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TopicChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2F6FED) : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;
  late Animation<double> _indicatorSpaceAnimation;
  late List<AnimationController> _dotControllers;
  final int _numDots = 3;
  final double _dotSize = 8;
  final double _dotSpacing = 4;

  @override
  void initState() {
    super.initState();
    _appearanceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(begin: 0.0, end: 1.0));

    _dotControllers = List<AnimationController>.generate(
      _numDots,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      ),
    );

    // تشغيل الأنيميشن
    _appearanceController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      for (var i = 0; i < _numDots; i++) {
        Future.delayed(Duration(milliseconds: i * 200), () {
          if (mounted) {
            _dotControllers[i].repeat(reverse: true);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    for (var controller in _dotControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizeTransition(
            sizeFactor: _indicatorSpaceAnimation,
            axis: Axis.horizontal,
            child: Row(
              children: List<Widget>.generate(_numDots, (index) {
                return Padding(
                  padding: EdgeInsets.only(
                      right: index < _numDots - 1 ? _dotSpacing : 0),
                  child: AnimatedBuilder(
                    animation: _dotControllers[index],
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -4 * _dotControllers[index].value),
                        child: Container(
                          width: _dotSize,
                          height: _dotSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F6FED).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(_dotSize / 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2F6FED).withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
