import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:chatbox/widgets/message_tile.dart';
import 'package:chatbox/widgets/input_field.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:flutter/services.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final OllamaClient client = OllamaClient();
  List<Model> models = [];
  bool isLoading = true;
  bool isGenerating = false;
  Model? selectedModel;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _listModels();
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

  Future<void> _generateCompletion(String promptMsg) async {
    if (selectedModel == null) return;
    setState(() {
      isGenerating = true;
    });

    try {
      final responseStream = client.generateCompletionStream(
        request: GenerateCompletionRequest(
          model: selectedModel!.model.toString(),
          prompt: promptMsg,
        ),
      );

      StringBuffer buffer = StringBuffer();
      await for (var response in responseStream) {
        buffer.write(response.response);
        setState(() {
          if (_messages.isNotEmpty && _messages.last['role'] == 'Ollama') {
            _messages.last['message'] = buffer.toString();
          } else {
            _messages.add({'role': 'Ollama', 'message': buffer.toString()});
          }
        });
      }
      setState(() {
        isGenerating = false; // Set to false once completed
      });
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
    }
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty && selectedModel != null) {
      setState(() {
        _messages.add({'role': 'You', 'message': _controller.text});
      });
      _generateCompletion(_controller.text);
      _controller.clear();
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        surfaceTintColor: AppColors.white,
        toolbarHeight: height * 0.1,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCodesandbox,
              color: AppColors.black,
              size: width * 0.02,
            ),
          ],
        ),
        actions: [
          HugeIcon(icon: HugeIcons.strokeRoundedBug01, color: AppColors.black),
          const SizedBox(width: 10.0),
          HugeIcon(
            icon: HugeIcons.strokeRoundedInformationCircle,
            color: AppColors.black,
          ),
          const SizedBox(width: 10.0),
          HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: AppColors.black,
          ),
          const SizedBox(width: 15.0),
        ],
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 100.0),
        child: Column(
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
                    'Ready to Chat? Let\'s Get Started!',
                    style: AppFonts.primaryFont(
                      color: AppColors.black,
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'NOTE: The performance completely depends on the model installed and the configuration of your setup.',
                    style: AppFonts.primaryFont(
                      color: Colors.grey[500]!,
                      fontSize: width * 0.009,
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
                    return MessageTile(
                      message: message['message']!,
                      isUser: isUser,
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
                onModelChange: (newValue) {
                  setState(() {
                    selectedModel = newValue;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
