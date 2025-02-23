import 'dart:async' show Timer;

import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/homepage');
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    // var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Text(
          'chatbox.',
          style: AppFonts.primaryFont(
            fontWeight: FontWeight.bold,
            fontSize: width * 0.03,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
