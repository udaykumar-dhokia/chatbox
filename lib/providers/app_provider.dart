import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class AppProvider extends ChangeNotifier {
  String _oldVersion = "";
  String _currentVersion = "";
  String _newAppUrl = "";
  bool _online = true;
  bool _isLoading = false;

  String get oldVersion => _oldVersion;
  String get currentVersion => _currentVersion;
  String get newAppUrl => _newAppUrl;
  bool get online => _online;
  bool get isLoading => _isLoading;

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    notifyListeners();
    await checkLatestVersion();
  }

  Future<void> checkLatestVersion() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    _isLoading = true;
    if (connectivityResult[0] == ConnectivityResult.none) {
      // No internet connection
      debugPrint('No internet connection. Skipping version check.');
      _online = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    const repositoryOwner = 'udaykumar-dhokia';
    const repositoryName = 'chatbox';
    final response = await http.get(
      Uri.parse(
        'https://api.github.com/repos/$repositoryOwner/$repositoryName/releases/latest',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final tagName = data['tag_name'];
      _oldVersion = tagName;
      final assets = data['assets'] as List<dynamic>;

      for (final asset in assets) {
        final assetDownloadUrl = asset['browser_download_url'];
        _newAppUrl = assetDownloadUrl.toString();
      }

      _isLoading = false;

      notifyListeners();

      if (_currentVersion != _oldVersion) {
        checkUpdate();
      }
    } else {
      debugPrint(
        'Failed to fetch GitHub release info. Status code: ${response.statusCode}',
      );
      _isLoading = false;
    }
  }

  void checkUpdate() {
    if (_currentVersion != _oldVersion) {
      launchUpdateUrl();
    }
  }

  Future<void> launchUpdateUrl() async {
    Uri _newAppUrl = Uri.parse(newAppUrl);
    if (!await launchUrl(_newAppUrl)) {
      throw Exception('Could not launch $_newAppUrl');
    }
  }
}
