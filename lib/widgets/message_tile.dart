import 'package:chatbox/constants/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/helpers/syntax_highlighter.dart';
import 'package:ollama_dart/ollama_dart.dart';

class MessageTile extends StatelessWidget {
  final String? message;
  final bool isUser;
  final bool isGenerating;
  final VoidCallback? onCopy;
  final VoidCallback? onReanswer;
  final Model? model;

  const MessageTile({
    Key? key,
    this.message = '',
    this.isUser = false,
    this.isGenerating = false,
    this.onCopy,
    this.onReanswer,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isGenerating
        ? ListTile(
          title: Container(
            margin: EdgeInsets.symmetric(horizontal: 200),
            child: Row(
              children: [
                Text(
                  '${model?.model} is typing',
                  style: AppFonts.secondaryFont(color: Colors.black),
                ),
                SizedBox(width: 8.0),
                CupertinoActivityIndicator(color: Colors.black),
              ],
            ),
          ),
        )
        : Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    // horizontal: 200.0,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.buttonColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: MarkdownBody(
                          syntaxHighlighter: CustomSyntaxHighlighter(),
                          selectable: true,
                          data: message!,
                          styleSheet: MarkdownStyleSheet(
                            codeblockDecoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            p: AppFonts.primaryFont(
                              color: isUser ? AppColors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // if (!isUser && onReanswer != null)
                    //   IconButton(
                    //     icon: Icon(
                    //       Icons.restart_alt_rounded,
                    //       color: Colors.grey,
                    //       size: 16,
                    //     ),
                    //     onPressed: onReanswer,
                    //   ),
                    IconButton(
                      icon: Icon(
                        Icons.copy_rounded,
                        color: Colors.grey,
                        size: 16,
                      ),
                      onPressed: onCopy,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }
}
