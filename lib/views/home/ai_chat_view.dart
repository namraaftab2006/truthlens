import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../utils/constants.dart';
import '../../services/ai_service.dart';

class AiChatView extends StatefulWidget {
  final String? initialMessage;

  const AiChatView({super.key, this.initialMessage});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  OverlayEntry? _listeningOverlay;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..addListener(() {
      if (_isListening) setState(() {});
    });

    if (widget.initialMessage?.isNotEmpty ?? false) {
      _addMessage(widget.initialMessage!, isUser: true);
      _simulateBotResponse(widget.initialMessage!);
    }
  }

  Future<void> _initSpeech() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
    }

    if (!micStatus.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }

    _speechAvailable = await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _speech.stop();
    _flutterTts.stop();
    _pulseController.dispose();
    _hideListeningOverlay();
    super.dispose();
  }

  void _addMessage(String message, {required bool isUser}) {
    setState(() {
      _messages.add({'sender': isUser ? 'user' : 'bot', 'message': message});
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _simulateBotResponse(String userMessage) async {
    String reply;
    try {
      reply = await AiService.sendMessage(userMessage);
    } catch (_) {
      reply = "🤖 This is a demo response. ML API not available yet.";
    }
    _addMessage(reply, isUser: false);
  }

  void _handleSend() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addMessage(text, isUser: true);
    _messageController.clear();
    _simulateBotResponse(text);
  }

  Future<void> _listen() async {
    var micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission required")),
        );
        return;
      }
    }

    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _hideListeningOverlay();
            setState(() => _isListening = false);
            _pulseController.stop();
          }
        },
        onError: (error) {
          print('Speech error: $error');
          _hideListeningOverlay();
          setState(() => _isListening = false);
          _pulseController.stop();
        },
      );
      if (!_speechAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available.')),
        );
        return;
      }
    }

    if (!_isListening) {
      setState(() => _isListening = true);
      _pulseController.repeat(reverse: true);
      _showListeningOverlay();

      await _speech.listen(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onResult: (result) {
          setState(() {
            _messageController.text = result.recognizedWords;
          });
        },
      );
    } else {
      setState(() => _isListening = false);
      _pulseController.stop();
      await _speech.stop();
      _hideListeningOverlay();
    }
  }

  void _showListeningOverlay() {
    _hideListeningOverlay();
    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.4,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, color: Colors.white, size: 48),
                SizedBox(height: 10),
                Text(
                  "Listening...",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlay);
    _listeningOverlay = overlay;
  }

  void _hideListeningOverlay() {
    _listeningOverlay?.remove();
    _listeningOverlay = null;
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
    setState(() => _isSpeaking = true);
  }

  Future<void> _stopSpeaking() async {
    await _flutterTts.stop();
    setState(() => _isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.accentColor,
        title: const Text('AI Chatbot', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                final text = msg['message'] ?? '';

                return Column(
                  crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser
                              ? Constants.accentColor.withOpacity(0.9)
                              : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 0),
                            bottomRight: Radius.circular(isUser ? 0 : 16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Text(
                          text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (!isUser)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, bottom: 8),
                        child: IconButton(
                          icon: Icon(
                            _isSpeaking
                                ? Icons.stop_circle
                                : Icons.volume_up_rounded,
                            color: Constants.accentColor,
                          ),
                          tooltip: _isSpeaking
                              ? 'Stop speaking'
                              : 'Listen to this reply',
                          onPressed: () {
                            if (_isSpeaking) {
                              _stopSpeaking();
                            } else {
                              _speak(text);
                            }
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey, width: 0.2)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                _isListening ? Colors.red.withOpacity(0.2) : Colors.transparent,
                boxShadow: _isListening
                    ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 4,
                  )
                ]
                    : [],
              ),
              transform: Matrix4.identity()
                ..scale(_isListening ? _pulseController.value : 1.0),
              child: IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.grey[700],
                  size: _isListening ? 30 : 26,
                ),
                onPressed: _listen,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _handleSend(),
                decoration: InputDecoration(
                  hintText: 'Type or speak your message...',
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Constants.accentColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
