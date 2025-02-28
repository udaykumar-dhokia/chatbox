import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int? selectedChatId;

  @override
  void initState() {
    super.initState();
    Provider.of<ChatProvider>(context, listen: false).loadChats();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    final chatProvider = Provider.of<ChatProvider>(context);
    final chats = chatProvider.chats;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.buttonColor.withOpacity(0.1),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 15,
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
                          style: AppFonts.primaryFont(
                            color: AppColors.white,
                            fontSize: width * 0.01,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child:
                    chats.isEmpty
                        ? Center(child: Text("No Chats Found"))
                        : ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            final chat = chats[index];
                            return ListTile(
                              title: Text(
                                chat['title'],
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.primaryFont(),
                              ),
                              hoverColor: AppColors.grey,
                              tileColor:
                                  selectedChatId == chat['id']
                                      ? AppColors.grey.withOpacity(0.2)
                                      : Colors.transparent,
                              onTap: () {
                                setState(() {
                                  selectedChatId = chat['id'];
                                });
                                Provider.of<ChatProvider>(
                                  context,
                                  listen: false,
                                ).setCurrentChatId(chat['id'], chat['title']);
                              },
                            );
                          },
                        ),
              ),
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
                        GestureDetector(
                          onTap: () {
                            // showGitHubDialog(context);
                          },
                          child: Text(
                            'GitHub',
                            style: AppFonts.primaryFont(color: AppColors.black),
                          ),
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
