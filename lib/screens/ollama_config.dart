import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/widgets/code_block.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class OllamaConfig extends StatefulWidget {
  const OllamaConfig({super.key});

  @override
  State<OllamaConfig> createState() => _OllamaConfigState();
}

class _OllamaConfigState extends State<OllamaConfig> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedStructureFail,
                color: AppColors.error,
              ),
              const SizedBox(height: 10),
              Text(
                'Ollama is not installed on your system.',
                style: AppFonts.primaryFont(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Follow the steps below to install Ollama:',
                style: AppFonts.primaryFont(fontSize: 16),
              ),
              const SizedBox(height: 10),

              Text(
                'For Linux and macOS:',
                style: AppFonts.primaryFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildCodeBlock('curl -fsSL https://ollama.com/install.sh | sh'),

              const SizedBox(height: 20),

              Text(
                'For Windows:',
                style: AppFonts.primaryFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              buildCodeBlock(
                'Invoke-WebRequest -Uri "https://ollama.com/install.ps1" '
                '-OutFile "\$env:TEMP\\install.ps1"\n'
                'Start-Process powershell -ArgumentList '
                '"-NoProfile -ExecutionPolicy Bypass -File \$env:TEMP\\install.ps1" '
                '-Wait -Verb RunAs',
              ),

              const SizedBox(height: 20),

              Text(
                'After installing Ollama, restart this application.',
                style: AppFonts.primaryFont(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              InkWell(
                onTap: () => {Navigator.pushReplacementNamed(context, '/')},
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.buttonColor,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedReload,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
