import 'package:chatbox/screens/homepage.dart';
import 'package:chatbox/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:ollama_dart/ollama_dart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await windowManager.ensureInitialized();

  // WindowOptions windowOptions = WindowOptions(
  //   minimumSize: Size(800, 600),
  //   center: true,
  //   backgroundColor: Colors.transparent,
  //   skipTaskbar: false,
  //   titleBarStyle: TitleBarStyle.normal,
  // );
  // windowManager.waitUntilReadyToShow(windowOptions, () async {
  //   await windowManager.show();
  //   await windowManager.focus();
  // });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'chatbox.',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Splash(),
        '/homepage': (context) => Homepage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final client = OllamaClient();
  List<Model> models = []; // List to store models
  bool isLoading = true; // Loading state

  Future<void> _listModels() async {
    try {
      final res = await client.listModels();
      setState(() {
        models = res.models ?? []; // Update the list of models
        isLoading = false; // Set loading to false
      });
    } catch (e) {
      print('Error fetching models: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _listModels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ollama Models')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : models.isEmpty
              ? Center(child: Text('No models found'))
              : ListView.builder(
                itemCount: models.length,
                itemBuilder: (context, index) {
                  final model = models[index];
                  return ListTile(
                    title: Text(model.model.toString()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size: ${model.size} bytes'),
                        Text('Modified: ${model.modifiedAt}'),
                        Text('Digest: ${model.digest}'),
                        Text('Format: ${model.details?.format ?? 'N/A'}'),
                        Text('Family: ${model.details?.family ?? 'N/A'}'),
                        Text(
                          'Parameter Size: ${model.details?.parameterSize ?? 'N/A'}',
                        ),
                        Text(
                          'Quantization Level: ${model.details?.quantizationLevel ?? 'N/A'}',
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
