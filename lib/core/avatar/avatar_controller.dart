import 'package:webview_flutter/webview_flutter.dart';

class AvatarController {
  WebViewController? _controller;

  void bind(WebViewController controller) {
    _controller = controller;
  }

  Future<void> play(String animation) async {
    await _controller?.runJavaScript(
      'window.loadAnimation("$animation");'
    );
  }

  Future<void> playSequence(List<String> animations) async {
    for (final anim in animations) {
      await play(anim);
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}