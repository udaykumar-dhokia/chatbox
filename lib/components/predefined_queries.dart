import 'package:chatbox/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class PredefinedQueries extends StatefulWidget {
  const PredefinedQueries({super.key});

  @override
  State<PredefinedQueries> createState() => _PredefinedQueriesState();
}

class _PredefinedQueriesState extends State<PredefinedQueries> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Row(
        spacing: 25,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          queryContainer(
            "What can you do",
            HugeIcons.strokeRoundedBrain,
            Colors.deepOrange,
            "Learn about the abilities.",
            width,
            height,
          ),
          queryContainer(
            "Tell me a joke!",
            HugeIcons.strokeRoundedLaughing,
            Colors.amber,
            "Enjoy a quick and funny joke.",
            width,
            height,
          ),
          queryContainer(
            "How does AI work?",
            HugeIcons.strokeRoundedBot,
            AppColors.buttonColor,
            "Brief of artificial intelligence.",
            width,
            height,
          ),
          queryContainer(
            "Give me a fun fact!",
            HugeIcons.strokeRoundedIdea,
            Colors.green,
            "Interesting and surprising fact.",
            width,
            height,
          ),
        ],
      ),
    );
  }

  Container queryContainer(
    String title,
    IconData icon,
    Color color,
    String description,
    var width,
    var height,
  ) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      width: (width * 0.87) * 0.16,
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary,
            spreadRadius: 0.1,
            blurRadius: 10.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: icon, color: color),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            description,
            style: TextStyle(color: AppColors.black, fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
