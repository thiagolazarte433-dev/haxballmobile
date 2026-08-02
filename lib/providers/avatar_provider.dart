import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el avatar personalizado (base64) elegido por el usuario para que
/// cualquier WebViewScreen que se abra después lo inyecte automáticamente.
class AvatarProvider extends ChangeNotifier {
  static const _kAvatarKey = 'custom_avatar_base64';

  String? _base64Avatar;
  String? get base64Avatar => _base64Avatar;
  bool get hasCustomAvatar => _base64Avatar != null && _base64Avatar!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _base64Avatar = prefs.getString(_kAvatarKey);
    notifyListeners();
  }

  Future<void> setAvatar(String base64Image) async {
    final prefs = await SharedPreferences.getInstance();
    if (base64Image.isEmpty) {
      _base64Avatar = null;
      await prefs.remove(_kAvatarKey);
    } else {
      _base64Avatar = base64Image;
      await prefs.setString(_kAvatarKey, base64Image);
    }
    notifyListeners();
  }
}
