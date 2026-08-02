import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kFpsLimit = 'fps_limit';
  static const _kFastExtrapolation = 'fast_extrapolation';
  static const _kControlsOpacity = 'controls_opacity';
  static const _kControlsSize = 'controls_size';
  static const _kDoNotTouch = 'do_not_touch_mode';
  static const _kNotifications = 'notifications_enabled';
  static const _kGamepadEnabled = 'gamepad_enabled';
  static const _kJoystickSide = 'joystick_side_left';

  int fpsLimit = 60;
  bool fastExtrapolation = true;
  double controlsOpacity = 0.75;
  double controlsSize = 1.0;
  bool doNotTouchMode = false;
  bool notificationsEnabled = false;
  bool gamepadEnabled = true;
  bool joystickOnLeft = true;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    fpsLimit = prefs.getInt(_kFpsLimit) ?? 60;
    fastExtrapolation = prefs.getBool(_kFastExtrapolation) ?? true;
    controlsOpacity = prefs.getDouble(_kControlsOpacity) ?? 0.75;
    controlsSize = prefs.getDouble(_kControlsSize) ?? 1.0;
    doNotTouchMode = prefs.getBool(_kDoNotTouch) ?? false;
    notificationsEnabled = prefs.getBool(_kNotifications) ?? false;
    gamepadEnabled = prefs.getBool(_kGamepadEnabled) ?? true;
    joystickOnLeft = prefs.getBool(_kJoystickSide) ?? true;
    notifyListeners();
  }

  Future<void> _save(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is int) await prefs.setInt(key, value);
    if (value is bool) await prefs.setBool(key, value);
    if (value is double) await prefs.setDouble(key, value);
    notifyListeners();
  }

  Future<void> setFpsLimit(int value) async {
    fpsLimit = value;
    await _save(_kFpsLimit, value);
  }

  Future<void> setFastExtrapolation(bool value) async {
    fastExtrapolation = value;
    await _save(_kFastExtrapolation, value);
  }

  Future<void> setControlsOpacity(double value) async {
    controlsOpacity = value;
    await _save(_kControlsOpacity, value);
  }

  Future<void> setControlsSize(double value) async {
    controlsSize = value;
    await _save(_kControlsSize, value);
  }

  Future<void> setDoNotTouchMode(bool value) async {
    doNotTouchMode = value;
    await _save(_kDoNotTouch, value);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled = value;
    await _save(_kNotifications, value);
  }

  Future<void> setGamepadEnabled(bool value) async {
    gamepadEnabled = value;
    await _save(_kGamepadEnabled, value);
  }

  Future<void> setJoystickOnLeft(bool value) async {
    joystickOnLeft = value;
    await _save(_kJoystickSide, value);
  }
}
