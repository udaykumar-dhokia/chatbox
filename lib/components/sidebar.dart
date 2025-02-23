import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withValues(alpha: 0.1),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCodesandbox,
                        color: AppColors.black,
                        size: 40,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        "v1.0.0",
                        style: AppFonts.primaryFont(color: AppColors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedAdd01,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'New Chat',
                          style: AppFonts.primaryFont(color: AppColors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(child: Column(children: [Text("No Chats Found")])),
              Container(
                child: Column(
                  spacing: 15,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedBug01,
                          color: AppColors.black,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Bug?',
                          style: AppFonts.primaryFont(color: AppColors.black),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedGithub01,
                          color: AppColors.black,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'GitHub',
                          style: AppFonts.primaryFont(color: AppColors.black),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings01,
                          color: AppColors.black,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Settings',
                          style: AppFonts.primaryFont(color: AppColors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
