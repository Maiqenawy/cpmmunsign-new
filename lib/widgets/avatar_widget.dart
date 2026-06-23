import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/avatar/avatar_controller.dart';

class AvatarWebView extends StatefulWidget {
  final AvatarController controller;

  const AvatarWebView({
    super.key,
    required this.controller,
  });

  @override
  State<AvatarWebView> createState() => _AvatarWebViewState();
}

class _AvatarWebViewState extends State<AvatarWebView> {
  late final WebViewController _webController;

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset("assets/avatar/index.html");

    widget.controller.bind(_webController);
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _webController);
  }
}