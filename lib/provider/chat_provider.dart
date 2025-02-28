import 'package:flutter/material.dart';
import 'package:chatbox/helpers/database_helper.dart';

class ChatProvider with ChangeNotifier {
  int? _currentChatId;
  String _chatTitle = '';
  List<Map<String, dynamic>> _chats = [];

  int? get currentChatId => _currentChatId;
  String get chatTitle => _chatTitle;
  List<Map<String, dynamic>> get chats => _chats;

  void setCurrentChatId(int chatId, String title) {
    _currentChatId = chatId;
    _chatTitle = title;
    notifyListeners();
  }

  void setChatTitle(String title) {
    _chatTitle = title;
    notifyListeners();
  }

  Future<void> loadChats() async {
    final dbHelper = DatabaseHelper();
    final chatList = await dbHelper.getChats();
    _chats = chatList;
    notifyListeners();
  }

  Future<void> clearChats() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearChats();
    _chats = [];
    notifyListeners();
  }
}
