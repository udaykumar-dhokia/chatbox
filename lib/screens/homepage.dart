import 'dart:async';

import 'package:chatbox/components/predefined_queries.dart';
import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/providers/app_provider.dart';
import 'package:chatbox/widgets/code_block.dart';
import 'package:chatbox/helpers/database_helper.dart';
import 'package:chatbox/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/widgets/message_tile.dart';
import 'package:chatbox/widgets/input_field.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final OllamaClient client = OllamaClient();
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Model> models = [];
  bool isLoading = true;
  bool isGenerating = false;
  bool isChatStarted = false;
  Model? selectedModel;
  String errorMessage = '';
  String chatTitle = '';
  int? currentChatId;

  @override
  void initState() {
    super.initState();
    _listModels();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatProvider = Provider.of<ChatProvider>(context);
    if (chatProvider.currentChatId != currentChatId) {
      _loadChatMessages(chatProvider.currentChatId!);
      setState(() {
        chatTitle = chatProvider.chatTitle;
      });
    }
  }

  Future<void> _listModels() async {
    isLoading = true;
    try {
      final res = await client.listModels();
      setState(() {
        models = res.models ?? [];
        isLoading = false;
        if (models.isNotEmpty) {
          selectedModel = models.first;
        } else {
          errorMessage =
              'No models found. Please ensure Ollama is set up correctly.';
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching models: $e';
      });
    }
  }

  Future<void> _loadChatMessages(int chatId) async {
    List<Map<String, dynamic>> messages = await dbHelper.getMessages(chatId);
    setState(() {
      currentChatId = chatId;
      _messages.clear();
      _messages.addAll(
        messages.map(
          (msg) => {'role': msg['sender'], 'message': msg['message']},
        ),
      );
    });
  }

  Future<void> _editChatTitle(BuildContext context) async {
    TextEditingController titleController = TextEditingController(
      text: chatTitle,
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedEdit02,
            color: AppColors.black,
          ),
          backgroundColor: AppColors.primary,
          title: Text(
            'Edit Chat Title',
            style: AppFonts.primaryFont(fontSize: 20),
          ),
          content: TextField(
            maxLength: 30,
            controller: titleController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.buttonColor),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.buttonColor),
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: "Enter new chat title",
              hintStyle: AppFonts.primaryFont(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: AppFonts.primaryFont()),
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(AppColors.buttonColor),
              ),
              onPressed: () async {
                String newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty && currentChatId != null) {
                  await dbHelper.updateChatTitle(currentChatId!, newTitle);
                  setState(() {
                    chatTitle = newTitle;
                  });
                  Provider.of<ChatProvider>(
                    context,
                    listen: false,
                  ).setChatTitle(newTitle);
                  Provider.of<ChatProvider>(context, listen: false).loadChats();
                }
                Navigator.of(context).pop();
              },
              child: Text(
                'Save',
                style: AppFonts.primaryFont(color: AppColors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNewChat() async {
    if (selectedModel == null) {
      setState(() {
        errorMessage = 'No model selected. Please select a model.';
      });
      return;
    }

    if (_controller.text.isNotEmpty || _messages.isNotEmpty) {
      int chatId = await dbHelper.insertChat(
        "New Chat",
        selectedModel!.model.toString(),
      );
      setState(() {
        currentChatId = chatId;
        _messages.clear();
        isChatStarted = true;
        chatTitle = "New Chat";
      });
      Provider.of<ChatProvider>(
        context,
        listen: false,
      ).setCurrentChatId(chatId, "New Chat");
      Provider.of<ChatProvider>(context, listen: false).loadChats();
    }
  }

  void _sendMessage() async {
    String userMessage = _controller.text;

    if (selectedModel == null) {
      setState(() {
        errorMessage = 'No model selected. Please select a model.';
      });
      return;
    }

    if (currentChatId == null) {
      await _startNewChat();
    }

    await dbHelper.insertMessage(currentChatId!, "You", userMessage);

    setState(() {
      _messages.add({'role': 'You', 'message': userMessage});
    });

    _controller.clear();
    _generateCompletion(userMessage);
  }

  Future<void> _generateCompletion(String promptMsg) async {
    if (selectedModel == null) return;
    setState(() {
      isGenerating = true;
    });

    try {
      String context = '';
      if (_messages.length >= 5) {
        context = _messages
            .sublist(_messages.length - 5)
            .map((msg) => '${msg['role']}: ${msg['message']}')
            .join('\n');
      }

      final responseStream = client.generateCompletionStream(
        request: GenerateCompletionRequest(
          model: selectedModel!.model.toString(),
          prompt:
              context.isNotEmpty
                  ? 'The context is provided as:\n $context\nNew prompt: $promptMsg \n generate the completion accordingly.'
                  : promptMsg,
        ),
      );

      StringBuffer buffer = StringBuffer();
      await for (var response in responseStream) {
        buffer.write(response.response);
        setState(() {
          if (_messages.isNotEmpty &&
              _messages.last['role'] == '${selectedModel!.model}') {
            _messages.last['message'] = buffer.toString();
          } else {
            _messages.add({
              'role': '${selectedModel!.model}',
              'message': buffer.toString(),
            });
          }
        });
      }

      // Save AI response
      await dbHelper.insertMessage(
        currentChatId!,
        selectedModel!.model.toString(),
        buffer.toString(),
      );

      setState(() {
        isGenerating = false;
      });
      _generateChatTitle();
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
    }
  }

  void _generateChatTitle() async {
    if (_messages.isNotEmpty &&
        selectedModel != null &&
        (chatTitle == 'New Chat' || chatTitle.isEmpty)) {
      final firstUserMessage = _messages.firstWhere(
        (msg) => msg['role'] == 'You',
        orElse: () => {'message': ''},
      );
      final newTitle =
          '${firstUserMessage['message']?.substring(0, 20) ?? 'Chat'}...';
      setState(() {
        chatTitle = newTitle;
      });
      if (currentChatId != null) {
        await dbHelper.updateChatTitle(currentChatId!, newTitle);
        Provider.of<ChatProvider>(
          context,
          listen: false,
        ).setChatTitle(newTitle);
      }
      Provider.of<ChatProvider>(context, listen: false).loadChats();
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Copied to clipboard')));
  }

  void _reanswerMessage(String message) {
    if (selectedModel != null) {
      _generateCompletion(message);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: AppColors.primary,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NOTE: The performance completely depends on the model installed and the configuration of your setup.',
              style: AppFonts.primaryFont(
                color: Colors.grey[500]!,
                fontSize: width * 0.008,
              ),
            ),
          ],
        ),
      ),
      appBar:
          models.isNotEmpty && !isLoading
              ? AppBar(
                automaticallyImplyLeading: false,
                surfaceTintColor: AppColors.white,
                toolbarHeight: height * 0.1,
                backgroundColor: AppColors.primary,
                centerTitle: true,
                title: InkWell(
                  onTap: () => {_editChatTitle(context)},
                  child: Text(
                    chatTitle.isNotEmpty ? chatTitle : '',
                    style: AppFonts.primaryFont(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.01,
                    ),
                  ),
                ),
              )
              : null,
      body:
          models.isNotEmpty && !isLoading
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (errorMessage.isNotEmpty)
                    ErrorWidget(errorMessage)
                  else if (_messages.isEmpty && !isGenerating)
                    Column(
                      children: [
                        Text(
                          'Hello 👋 there, What can I help with?',
                          style: AppFonts.primaryFont(
                            color: AppColors.black,
                            fontSize: width * 0.034,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        PredefinedQueries(),
                      ],
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length + (isGenerating ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _messages.length && isGenerating) {
                            return MessageTile(
                              isGenerating: true,
                              model: selectedModel,
                            );
                          }
                          final message = _messages[index];
                          final isUser = message['role'] == 'You';
                          final model = message['role'];
                          return MessageTile(
                            message: message['message']!,
                            isUser: isUser,
                            modelName: model,
                            onCopy: () => _copyToClipboard(message['message']!),
                            onReanswer:
                                () => _reanswerMessage(message['message']!),
                          );
                        },
                      ),
                    ),
                  if (errorMessage.isEmpty)
                    InputField(
                      controller: _controller,
                      onSendMessage: _sendMessage,
                      models: models,
                      selectedModel: selectedModel,
                      isGenerating: isGenerating,
                      isChatStarted: isChatStarted,
                      onNewChat: () async {
                        await _startNewChat();
                      },
                      onModelChange: (newValue) {
                        if (!isChatStarted) {
                          setState(() {
                            selectedModel = newValue;
                          });
                        }
                      },
                    ),
                ],
              )
              : isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Icon
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedArtificialIntelligence03,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 10),

                      // Error Message
                      Text(
                        'No models found. Please install a model.',
                        style: AppFonts.primaryFont(
                          color: AppColors.error,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // Documentation Header
                      Text(
                        'Available Models:',
                        style: AppFonts.primaryFont(
                          color: AppColors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),

                      // Model 1: Mistral
                      Text(
                        '1. Mistral (Small, fast, and efficient model)',
                        style: AppFonts.primaryFont(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildCodeBlock('ollama pull mistral'),

                      // Model 2: Llama 2
                      const SizedBox(height: 10.0),
                      Text(
                        '2. LLaMA 2 (Meta’s open-source language model)',
                        style: AppFonts.primaryFont(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildCodeBlock('ollama pull llama2'),

                      // Model 3: DeepSeek-R1
                      const SizedBox(height: 10.0),
                      Text(
                        '3. DeepSeek-R1 (Optimized for reasoning tasks)',
                        style: AppFonts.primaryFont(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      buildCodeBlock('ollama run deepseek-r1:7b'),

                      const SizedBox(height: 20.0),

                      // Restart Message
                      Text(
                        'After installing a model, restart this application.',
                        style: AppFonts.primaryFont(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      InkWell(
                        onTap:
                            () => {
                              Navigator.pushReplacementNamed(context, '/'),
                            },
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
