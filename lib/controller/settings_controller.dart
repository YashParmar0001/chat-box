import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController extends GetxController {
  final _autoDownload = true.obs;

  bool get autoDownload => _autoDownload.value;

  @override
  Future<void> onInit() async {
    log('Initializing settings controller', name: 'Settings');
    final prefs = await SharedPreferences.getInstance();
    _autoDownload.value = prefs.getBool('auto_download') ?? true;
    super.onInit();
  }

  Future<void> setAutoDownload(bool autoDownload) async {
    _autoDownload.value = autoDownload;
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('auto_download', autoDownload);
  }
}
