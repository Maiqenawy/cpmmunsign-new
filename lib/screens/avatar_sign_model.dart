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
  final int totalFrames;
  final List<AvatarFrame> frames;

  AvatarSign({
    required this.word,
    required this.totalFrames,
    required this.frames,
  });

  factory AvatarSign.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvatarSign(
      word: json["word"],
      totalFrames: json["total_frames"],
      frames: (json["frames"] as List)
          .map((e) => AvatarFrame.fromJson(e))
          .toList(),
    );
  }
}
