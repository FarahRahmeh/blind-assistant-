import 'dart:async'; // Import the async library for Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:camera/camera.dart';
import '../constants/colors.dart';
import '../controllers/camera_controller.dart';
import '../controllers/voice_controller.dart';

// Convert to a StatefulWidget to use initState
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Initialize controllers here
  final voiceController = Get.put(VoiceController());
  final camController = Get.put(CameraInteractionController());

  @override
  void initState() {
    super.initState();
    startMicTimer();
  }

  /// Starts a 5-second timer and then begins listening.
  void startMicTimer() {
    Timer(const Duration(seconds: 15), () {
      if (mounted) {
        print("Timer finished. Auto-starting microphone...");
        voiceController.listen();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 30),
              Text(
                camController.isProcessing.value
                    ? "Analyzing scene..."
                    : voiceController.statusMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              if (voiceController.isListening.value ||
                  camController.isProcessing.value)
                Column(
                  children: [
                    SizedBox(
                      width: 400,
                      child: Lottie.asset('assets/animation/loading.json'),
                    ),
                    if (voiceController.isListening.value)
                      SizedBox(
                        height: 80,
                        child: Lottie.asset('assets/animation/wave.json'),
                      ),
                  ],
                )
              else
                SizedBox(
                  width: 400,
                  child: Lottie.asset('assets/animation/loading.json'),
                ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ElevatedButton(
                  //   onPressed: camController.isProcessing.value
                  //       ? null
                  //       : camController.captureAndAnalyze,
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: camController.isProcessing.value
                  //         ? Colors.grey
                  //         : Colors.orangeAccent,
                  //     shape: const CircleBorder(),
                  //     padding: const EdgeInsets.all(20),
                  //   ),
                  //   child: const Icon(Icons.camera_alt, size: 32),
                  // ),
                  ElevatedButton(
                    onPressed: () {
                      if (!voiceController.isListening.value) {
                        voiceController.listen();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tealGreen,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.mic, size: 32),
                  ),
                  ElevatedButton(
                    onPressed: voiceController.repeat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mintGreen,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.replay, size: 32),
                  ),
                  ElevatedButton(
                    onPressed: voiceController.isSpeaking.value
                        ? voiceController.stopSpeaking
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softLavender,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.stop, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mic,
                    color: voiceController.isListening.value
                        ? Colors.green
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Mic: ${voiceController.isListening.value ? 'Listening' : 'Ready'}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 24),
                  Icon(
                    Icons.camera,
                    color: camController.isProcessing.value
                        ? Colors.red
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Cam: ${camController.isProcessing.value ? 'Active' : 'Idle'}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          )),
        ),
      ),
    );
  }
}