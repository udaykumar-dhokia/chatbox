import 'dart:io';
import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/helpers/pdf_helper.dart';
import 'package:chatbox/providers/app_provider.dart';
import 'package:chatbox/providers/chat_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

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
    final chatProvider = Provider.of<ChatProvider>(context);
    final chats = chatProvider.chats;

    Future<void> _launchUrl(String url) async {
      Uri _url = Uri.parse(url);
      if (!await launchUrl(_url)) {
        throw Exception('Could not launch $_url');
      }
    }

    Future<void> _saveChatAsPdf(int chatId, String chatTitle) async {
      final messages = await Provider.of<ChatProvider>(
        context,
        listen: false,
      ).getMessages(chatId);
      final pdfHelper = PdfHelper();
      await pdfHelper.saveChatToPdf(chatTitle, messages);

      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$chatTitle.pdf');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Saved to ${file.path}')));
    }

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
            spacing: 15,
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
                        color: AppColors.black,
                        size: 40,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        "v1.0.0",
                        style: AppFonts.primaryFont(
                          color: AppColors.black.withValues(alpha: 0.3),
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
                          physics: BouncingScrollPhysics(),
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
                                        ? AppColors.grey.withValues(alpha: 0.2)
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
                                  padding: EdgeInsets.zero,
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
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/homepage',
                                      );
                                    } else if (result == 'save') {
                                      _saveChatAsPdf(chat['id'], chat['title']);
                                    }
                                  },
                                  itemBuilder:
                                      (BuildContext context) => [
                                        PopupMenuItem<String>(
                                          value: 'save',
                                          child: Row(
                                            spacing: 5,
                                            children: [
                                              HugeIcon(
                                                size: 15,
                                                icon:
                                                    HugeIcons
                                                        .strokeRoundedDownload01,
                                                color: AppColors.black,
                                              ),
                                              Text(
                                                'Save',
                                                style: AppFonts.primaryFont(
                                                  color: AppColors.black,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
              Column(
                spacing: 15,
                children: [
                  InkWell(
                    onTap:
                        () => {
                          _launchUrl(
                            'mailto:udaykumardhokia@gmail.com?subject=chatbox%20-%20Bug%20Report&body=Please%20describe%20the%20bug%20you%20encountered%20in%20detail%20with%20screenshots.',
                          ),
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap:
                              () => {
                                _launchUrl(
                                  'mailto:udaykumardhokia@gmail.com?subject=Bug%20Report&body=Please%20describe%20the%20bug%20you%20encountered%20in%20detail%20with%20screenshots.',
                                ),
                              },
                          child: InkWell(
                            onTap:
                                () => {
                                  _launchUrl(
                                    'mailto:udaykumardhokia@gmail.com?subject=Bug%20Report&body=Please%20describe%20the%20bug%20you%20encountered%20in%20detail%20with%20screenshots.',
                                  ),
                                },
                            child: HugeIcon(
                              icon: HugeIcons.strokeRoundedBug01,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'Bug?',
                          style: AppFonts.primaryFont(color: AppColors.black),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap:
                        () => {
                          _launchUrl(
                            'https://www.github.com/udaykumar-dhokia/chatbox',
                          ),
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap:
                              () => {
                                _launchUrl(
                                  'https://www.github.com/udaykumar-dhokia/chatbox',
                                ),
                              },
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedGithub01,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        InkWell(
                          onTap:
                              () => {
                                _launchUrl(
                                  'https://www.github.com/udaykumar-dhokia/chatbox',
                                ),
                              },
                          child: Text(
                            'GitHub',
                            style: AppFonts.primaryFont(color: AppColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap:
                        () => {
                          _launchUrl(
                            'https://www.buymeacoffee.com/udthedeveloper',
                          ),
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap:
                              () => {
                                _launchUrl(
                                  'https://www.buymeacoffee.com/udthedeveloper',
                                ),
                              },
                          child: HugeIcon(
                            icon: Icons.favorite,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        InkWell(
                          onTap:
                              () => {
                                _launchUrl(
                                  'https://www.buymeacoffee.com/udthedeveloper',
                                ),
                              },
                          child: Text(
                            'Support',
                            style: AppFonts.primaryFont(color: AppColors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Consumer<AppProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? Center(
                        child: CupertinoActivityIndicator(
                          color: AppColors.grey,
                        ),
                      )
                      : !provider.online
                      ? InkWell(
                        onTap: () {
                          provider.checkLatestVersion();
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                color: AppColors.black,
                                size: 15,
                              ),
                              Text(
                                "v${provider.currentVersion}",
                                style: AppFonts.primaryFont(
                                  color: AppColors.black,
                                  fontSize: (width * 0.13) * 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : provider.currentVersion != provider.oldVersion
                      ? InkWell(
                        onTap: () {
                          _launchUrl(provider.newAppUrl);
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedReload,
                                color: AppColors.white,
                                size: 15,
                              ),
                              Text(
                                "Update Available",
                                style: AppFonts.primaryFont(
                                  color: AppColors.white,
                                  fontSize: (width * 0.13) * 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : InkWell(
                        onTap: () {
                          provider.checkLatestVersion();
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                color: AppColors.black,
                                size: 15,
                              ),
                              Text(
                                "v${provider.currentVersion}",
                                style: AppFonts.primaryFont(
                                  color: AppColors.black,
                                  fontSize: (width * 0.13) * 0.05,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
