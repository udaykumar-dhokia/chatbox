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
                color: AppColors.buttonColor.withValues(alpha: 0.1),
                spreadRadius: 0.1,
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 30.0),
                  Text(
                    "History",
                    style: AppFonts.primaryFont(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.01,
                    ),
                  ),
                  const SizedBox(height: 15),
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
                            return Tooltip(
                              message: chat['title'],
                              waitDuration: Duration(seconds: 1),
                              textStyle: AppFonts.primaryFont(
                                color: AppColors.white,
                              ),
                              child: ListTile(
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
                                trailing: PopupMenuButton<String>(
                                  tooltip: "options",
                                  color: AppColors.white,
                                  shadowColor: AppColors.primary,
                                  icon: HugeIcon(
                                    icon: HugeIcons.strokeRoundedMoreHorizontal,
                                    color: AppColors.grey,
                                    size: 15,
                                  ),
                                  onSelected: (String result) {
                                    if (result == 'delete') {
                                      Provider.of<ChatProvider>(
                                        context,
                                        listen: false,
                                      ).deleteChat(chat['id']);
                                    } else if (result == 'download') {
                                      // Handle download action
                                    }
                                  },
                                  itemBuilder:
                                      (BuildContext context) => [
                                        // PopupMenuItem<String>(
                                        //   value: 'download',
                                        //   child: Row(
                                        //     spacing: 5,
                                        //     children: [
                                        //       HugeIcon(
                                        //         icon:
                                        //             HugeIcons
                                        //                 .strokeRoundedDownload04,
                                        //         color: AppColors.grey,
                                        //         size: 15,
                                        //       ),
                                        //       Text(
                                        //         'Save',
                                        //         style: AppFonts.primaryFont(
                                        //           fontSize: 14,
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            spacing: 5,
                                            children: [
                                              HugeIcon(
                                                size: 15,
                                                icon:
                                                    HugeIcons
                                                        .strokeRoundedDelete01,
                                                color: AppColors.error,
                                              ),
                                              Text(
                                                'Delete',
                                                style: AppFonts.primaryFont(
                                                  color: AppColors.error,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ),
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
