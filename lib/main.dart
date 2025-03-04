import 'dart:io';

import 'package:chatbox/layouts/layout.dart';
import 'package:chatbox/providers/chat_provider.dart';
import 'package:chatbox/screens/ollama_config.dart';
import 'package:chatbox/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    setWindowTitle('chatbox');
    setWindowMinSize(const Size(1600, 1000));
    setWindowMaxSize(Size.infinite);
    setWindowFrame(const Rect.fromLTWH(100, 100, 1280, 720));
  }

  WindowOptions windowOptions = WindowOptions(
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ChangeNotifierProvider(create: (context) => ChatProvider(), child: MyApp()),
  );
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
        '/homepage': (context) => Layout(),
        '/config_ollama': (context) => OllamaConfig(),
      },
    );
  }
}
