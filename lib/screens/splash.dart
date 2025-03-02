import 'dart:async';
import 'dart:io';

import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _checkOllamaInstallation();
  }

  Future<void> _checkOllamaInstallation() async {
    String checkCommand = Platform.isWindows ? 'where' : 'which';
    List<String> args = Platform.isWindows ? ['ollama'] : ['ollama'];

    try {
      final result = await Process.run(checkCommand, args);
      String output = result.stdout.toString().trim();
      if (result.exitCode != 0 || output.isEmpty) {
        Navigator.pushReplacementNamed(context, '/config_ollama');
      } else {
        Navigator.pushReplacementNamed(context, '/homepage');
      }
    } catch (e) {
      print('Error checking Ollama installation: $e');
      Navigator.pushReplacementNamed(context, '/config_ollama');
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedCodesandbox,
                  color: AppColors.buttonColor,
                  size: 40,
                ),
                const SizedBox(width: 4.0),
                Text(
                  "v1.0.0",
                  style: AppFonts.primaryFont(
                    color: AppColors.buttonColor.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            Text(
              "chatbox.",
              style: AppFonts.primaryFont(
                color: AppColors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
