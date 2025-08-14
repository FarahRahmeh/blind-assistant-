import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seespeak/constants/colors.dart';
import 'screens/main_screen.dart';

class VoiceAssistApp extends StatelessWidget {
  const VoiceAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Voice Assistant',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary:  tealGreen,
          secondary: softLavender,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(24),
          ),
        ),
      ),
      home: MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
