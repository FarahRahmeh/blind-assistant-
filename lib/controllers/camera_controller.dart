import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../services/ai_service.dart';

class CameraInteractionController extends GetxController {
  late CameraController cameraController;
  var isCameraInitialized = false.obs;
  var isProcessing = false.obs;
  final FlutterTts tts = FlutterTts();

  @override
  void onInit() {
    super.onInit();
    initCamera();
    tts.setSpeechRate(0.5);
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final backCam = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.back);
    cameraController = CameraController(backCam, ResolutionPreset.medium);
    await cameraController.initialize();
    isCameraInitialized.value = true;
  }

  Future<void> captureAndAnalyze() async {
    isProcessing.value = true;

    final filePath = join(
      (await getTemporaryDirectory()).path,
      "${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    await cameraController.takePicture().then((file) async {
      final response = await AIService().sendImageForPrediction(File(file.path));
      await tts.speak(response ?? "I couldn't detect anything.");
    });

    isProcessing.value = false;
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
