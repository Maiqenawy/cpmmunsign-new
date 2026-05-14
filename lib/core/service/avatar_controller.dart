
import 'package:flutter/material.dart';
class AvatarController extends ChangeNotifier {
  List<String> queue = [];
  String current = "idle";

  void setSigns(List<String> signs) {
    queue = signs;
    playNext();
  }

  void playNext() async {
    if (queue.isEmpty) {
      current = "idle";
      notifyListeners();
      return;
    }

    current = queue.removeAt(0);
    notifyListeners();

    await Future.delayed(Duration(seconds: 2));
    playNext();
  }
}