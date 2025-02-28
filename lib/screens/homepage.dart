import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:chatbox/helpers/database_helper.dart';
import 'package:chatbox/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/widgets/message_tile.dart';
import 'package:chatbox/widgets/input_field.dart';
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

  Future<void> _startNewChat() async {
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

  void _sendMessage() async {
    String userMessage = _controller.text;
    _controller.clear();

    if (currentChatId == null) {
      await _startNewChat();
    }

    // Save user message
    await dbHelper.insertMessage(currentChatId!, "You", userMessage);

    setState(() {
      _messages.add({'role': 'You', 'message': userMessage});
    });

    // Generate AI response
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: AppColors.white,
        toolbarHeight: height * 0.1,
        backgroundColor: AppColors.primary,
        centerTitle: true,
        title: Text(
          chatTitle.isNotEmpty ? chatTitle : '',
          style: AppFonts.primaryFont(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.01,
          ),
        ),
      ),
      body: Column(
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
                  'Hello 👋 there, What would you like to talk?',
                  style: AppFonts.primaryFont(
                    color: AppColors.black,
                    fontSize: width * 0.034,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    onReanswer: () => _reanswerMessage(message['message']!),
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
      ),
    );
  }
}
