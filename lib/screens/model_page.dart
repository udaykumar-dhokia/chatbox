import 'package:flutter/material.dart';
import 'package:chatbox/constants/app_colors.dart';
import 'package:chatbox/constants/app_fonts.dart';
import 'package:ollama_dart/ollama_dart.dart';

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  final TextEditingController _searchController = TextEditingController();
  final OllamaClient client = OllamaClient();
  List<Model> models = [
    Model(model: 'yarn-llama3:13b-128k-q4_1'),
    Model(model: 'yarn-llama2:7b-128k-q4_1'),
    Model(model: 'yarn-llama1:3b-128k-q4_1'),
    Model(model: 'qwen2.5:1.5b'),
  ];
  bool isLoading = false;
  bool isPulling = false;
  String errorMessage = '';
  String pullStatus = '';

  @override
  void initState() {
    super.initState();
    // _listModels(); // Commented out to use predefined models
  }

  Future<void> _pullModelStream(String modelName) async {
    setState(() {
      isPulling = true;
      pullStatus = 'Pulling model...';
    });

    try {
      final stream = client.pullModelStream(
        request: PullModelRequest(model: 'gemma:2b'),
      );
      await for (final res in stream) {
        setState(() {
          pullStatus = res.status.toString();
        });
        print(res.status.toString());
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error pulling model: $e';
      });
    } finally {
      setState(() {
        isPulling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.sizeOf(context).width;
    var height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Models',
          style: AppFonts.primaryFont(
            color: AppColors.black,
            fontSize: width * 0.02,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter model name...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _pullModelStream(_searchController.text);
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (errorMessage.isNotEmpty)
              Text(errorMessage, style: TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: models.length,
                  itemBuilder: (context, index) {
                    final model = models[index];
                    return ListTile(
                      title: Text(model.model.toString()),
                      onTap: () {
                        _pullModelStream(model.model.toString());
                      },
                    );
                  },
                ),
              ),
            if (isPulling)
              Column(
                children: [
                  SizedBox(height: 16.0),
                  LinearProgressIndicator(),
                  SizedBox(height: 8.0),
                  Text(pullStatus),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
