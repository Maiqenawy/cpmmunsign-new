class AvatarFrame {
  final List leftHand;
  final List rightHand;

  AvatarFrame({
    required this.leftHand,
    required this.rightHand,
  });

  factory AvatarFrame.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvatarFrame(
      leftHand: json["left_hand"],
      rightHand: json["right_hand"],
    );
  }
}

class AvatarSign {
  final String word;
  final int frames;
  final int landmarksPerFrame;
  final List<dynamic> landmarks;

  AvatarSign({
    required this.word,
    required this.frames,
    required this.landmarksPerFrame,
    required this.landmarks,
  });

  factory AvatarSign.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvatarSign(
      word: json["word"],
      frames: json["frames"],
      landmarksPerFrame: json["landmarks_per_frame"],
      landmarks: json["landmarks"],
    );
  }
}
