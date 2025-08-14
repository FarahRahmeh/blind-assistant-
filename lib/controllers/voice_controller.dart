import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'camera_controller.dart';

class VoiceController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();

  var isListening = false.obs;
  var isSpeaking = false.obs;
  var isProcessing = false.obs;
  var statusMessage = "Hello, how can I assist you today?".obs;

  late final Map<String, Function> _commands;

  @override
  Future<void> onInit() async {
    super.onInit();
    _commands = {
      "repeat": repeat,
    };
    try {
      await _initTTS();
      await _initSTT();
      await speak(statusMessage.value);
    } catch (e) {
      statusMessage.value = "Voice system failed to initialize: $e";
    }
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
      // Restart listening after it finished speaking.
      if (!isListening.value) {
        listen();
      }
    });
  }

  Future<void> _initSTT() async {
    await speech.initialize(onStatus: (status) {
      if (status == 'notListening' && !isSpeaking.value) {
        listen();
      }
    });
  }

  Future<void> speak(String text) async {
    if (isSpeaking.value) await flutterTts.stop();
    isSpeaking.value = true;
    await flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();
    isSpeaking.value = false;
  }

  void listen() {
    isListening.value = true;
    isProcessing.value = false;
   // statusMessage.value = "Please speak now...";

    if (isSpeaking.value) {
      flutterTts.stop();
    }

    speech.listen(onResult: (result) {
      if (result.finalResult) {
        final heard = result.recognizedWords.toLowerCase();
        isListening.value = false;
        isProcessing.value = true;

        Future.delayed(const Duration(milliseconds: 500), () {
          _handleVoiceCommand(heard);
          isProcessing.value = false;
        });
      }
    });
  }

  void _handleVoiceCommand(String command) {
    for (var key in _commands.keys) {
      if (command.contains(key)) {
        _commands[key]!();
        return;
      }
    }
    statusMessage.value = "Heard: $command";
    speak(statusMessage.value);
  }

  void repeat() {
    speak(statusMessage.value);
  }

  @override
  void onClose() {
    flutterTts.stop();
    speech.stop();
    super.onClose();
  }

  void handleSpeechResult(String recognizedWords) {
    final command = recognizedWords.toLowerCase();

    if (command.contains('describe')) {
      final camController = Get.find<CameraInteractionController>();
      camController.captureAndAnalyze();
    }
  }
}