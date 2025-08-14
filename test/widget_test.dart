import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const VoiceAssistApp());
}

class VoiceAssistApp extends StatelessWidget {
  const VoiceAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.amber,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const VoiceAssistantScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final _tts = FlutterTts();
  final _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isSpeaking = false;
  String _statusMessage = "Hello, how can I assist you today?";
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _initializeTts();
      await _initializeStt();
      await _speak(_statusMessage);
      setState(() => _isInitialized = true);
    } catch (e) {
      setState(() => _statusMessage = "Initialization failed: $e");
    }
  }

  Future<void> _initializeTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    _tts.setCompletionHandler(() {
      setState(() => _isSpeaking = false);
    });
  }

  Future<void> _initializeStt() async {
    final initialized = await _speech.initialize(
      onError: (error) => setState(() {
        _isListening = false;
        _statusMessage = "Speech recognition error: ${error.errorMsg}";
      }),
    );
    if (!initialized) {
      setState(() => _statusMessage = "Failed to initialize speech recognition");
    }
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) await _tts.stop();
    setState(() {
      _isSpeaking = true;
      _statusMessage = text;
    });
    await _tts.speak(text);
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();
    setState(() => _isSpeaking = false);
  }

  Future<void> _startListening() async {
    if (!_isInitialized || _isListening) return;

    setState(() {
      _isListening = true;
      _statusMessage = "Please speak now...";
    });
    await _speak(_statusMessage);

    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          final spokenText = result.recognizedWords;
          setState(() {
            _isListening = false;
            _statusMessage = "Heard: $spokenText";
          });
          _speak(_statusMessage);
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.hearing,
                size: 100,
                color: Colors.tealAccent,
              ),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              if (_isListening)
                const CircularProgressIndicator(color: Colors.teal),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: Icons.mic,
                    color: Colors.teal,
                    onPressed: _isListening || !_isInitialized ? null : _startListening,
                  ),
                  _ActionButton(
                    icon: Icons.replay,
                    color: Colors.amber,
                    onPressed: () => _speak(_statusMessage),
                  ),
                  _ActionButton(
                    icon: Icons.stop,
                    color: Colors.redAccent,
                    onPressed: _isSpeaking ? _stopSpeaking : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _StatusIndicator(
                isSpeaking: _isSpeaking,
                isInitialized: _isInitialized,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.5),
      ),
      child: Icon(icon, size: 32),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool isSpeaking;
  final bool isInitialized;

  const _StatusIndicator({
    required this.isSpeaking,
    required this.isInitialized,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.signal_cellular_alt,
          color: isInitialized
              ? (isSpeaking ? Colors.green : Colors.grey)
              : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          isInitialized
              ? "TTS: ${isSpeaking ? 'Speaking' : 'Ready'}"
              : "TTS: Not initialized",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}