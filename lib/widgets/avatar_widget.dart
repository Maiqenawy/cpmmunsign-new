import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class MyProjectAvatar extends StatelessWidget {
  final String animation; // لتغيير الحركة حسب الصفحة

  const MyProjectAvatar({Key? key, this.animation = 'idle'}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModelViewer(
      src: 'assets/cartoon_male_characters_-_low-poly_3d_model.glb',
      backgroundColor: Colors.transparent, // لجعل الجرادينت يظهر
      animationName: animation,
      autoPlay: true,
      cameraControls: true, 
    );
  }
}
