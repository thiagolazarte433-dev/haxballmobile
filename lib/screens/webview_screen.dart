import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../providers/settings_provider.dart';
import '../providers/avatar_provider.dart';
import '../theme/app_theme.dart';
import '../utils/js_injector.dart';
import '../widgets/virtual_joystick.dart';
import '../widgets/kick_button.dart';
import '../widgets/ping_indicator.dart';

class WebViewScreen extends StatefulWidget {
  final String initialUrl;

  const WebViewScreen({super.key, required this.initialUrl});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _inRoom = false;
  bool _doNotTouch = false;

  Set<HbDirection> _activeDirections = {};

  static const Map<HbDirection, _KeyBinding> _keyBindings = {
    HbDirection.up: _KeyBinding('ArrowUp', 38),
    HbDirection.down: _KeyBinding('ArrowDown', 40),
    HbDirection.left: _KeyBinding('ArrowLeft', 37),
    HbDirection.right: _KeyBinding('ArrowRight', 39),
  };

  static const _KeyBinding _kickBinding = _KeyBinding('KeyX', 88);

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppTheme.background)
      ..addJavaScriptChannel(
        'RoomState',
        onMessageReceived: (message) => _onRoomStateChanged(message.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) async {
            setState(() => _isLoading = false);
            await _injectStartupScripts();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      androidController.setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  Future<void> _injectStartupScripts() async {
    final settings = context.read<SettingsProvider>();
    final avatar = context.read<AvatarProvider>();

    await _controller.runJavaScript(JsInjector.mobileOptimizations);
    await _controller.runJavaScript(JsInjector.roomDetectorWatcher);
    await _controller.runJavaScript(JsInjector.applyFpsLimit(settings.fpsLimit));

    if (avatar.hasCustomAvatar) {
      await _controller.runJavaScript(JsInjector.setCustomAvatar(avatar.base64Avatar!));
    }
  }

  void _onRoomStateChanged(String state) {
    final inRoom = state == 'IN_ROOM';
    if (inRoom == _inRoom) return;
    setState(() => _inRoom = inRoom);

    if (inRoom) {
      _enterImmersiveLandscape();
      WakelockPlus.enable();
    } else {
      _exitImmersiveLandscape();
      WakelockPlus.disable();
    }
  }

  Future<void> _enterImmersiveLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _exitImmersiveLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _sendKey(_KeyBinding binding, bool down) {
    return _controller.runJavaScript(
      JsInjector.dispatchKey(code: binding.code, keyCode: binding.keyCode, keyDown: down),
    );
  }

  Future<void> _onJoystickDirectionsChanged(Set<HbDirection> next) async {
    final released = _activeDirections.difference(next);
    final pressed = next.difference(_activeDirections);

    for (final dir in released) {
      await _sendKey(_keyBindings[dir]!, false);
    }
    for (final dir in pressed) {
      await _sendKey(_keyBindings[dir]!, true);
    }
    _activeDirections = next;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return PopScope(
      canPop: !_inRoom,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _inRoom) {
          _controller.canGoBack().then((can) {
            if (can) _controller.goBack();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: _doNotTouch,
              child: WebViewWidget(controller: _controller),
            ),

            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primary)),

            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: SafeArea(
                child: Row(
                  children: [
                    _FloatingIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    const PingIndicator(),
                    const Spacer(),
                    _FloatingIconButton(
                      icon: _doNotTouch ? Icons.lock_rounded : Icons.lock_open_rounded,
                      active: _doNotTouch,
                      onTap: () => setState(() => _doNotTouch = !_doNotTouch),
                    ),
                  ],
                ),
              ),
            ),

            if (_inRoom && !_doNotTouch) ...[
              Positioned(
                left: settings.joystickOnLeft ? 20 : null,
                right: settings.joystickOnLeft ? null : 20,
                bottom: 24,
                child: VirtualJoystick(
                  size: 140 * settings.controlsSize,
                  opacity: settings.controlsOpacity,
                  onDirectionsChanged: _onJoystickDirectionsChanged,
                ),
              ),
              Positioned(
                right: settings.joystickOnLeft ? 28 : null,
                left: settings.joystickOnLeft ? null : 28,
                bottom: 32,
                child: KickButton(
                  size: 96 * settings.controlsSize,
                  opacity: settings.controlsOpacity,
                  onKickDown: () => _sendKey(_kickBinding, true),
                  onKickUp: () => _sendKey(_kickBinding, false),
                ),
              ),
            ],

            if (_doNotTouch)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '🔒 Pantalla bloqueada — toca el candado para reactivar',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeyBinding {
  final String code;
  final int keyCode;
  const _KeyBinding(this.code, this.keyCode);
}

class _FloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const _FloatingIconButton({required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: active ? AppTheme.primary.withOpacity(0.85) : AppTheme.surface.withOpacity(0.75),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
