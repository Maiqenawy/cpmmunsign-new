class AvatarSign {
  final String word;
  final int avatarLabelIndex;
  final int frames;
  final int landmarksPerFrame;
  final List<List<double>> landmarks;

  AvatarSign({
    required this.word,
    required this.avatarLabelIndex,
    required this.frames,
    required this.landmarksPerFrame,
    required this.landmarks,
  });

  int get framesCount => landmarks.length;

  factory AvatarSign.fromJson(Map<String, dynamic> json) {
    // معالجة الـ landmarks بأمان لمنع مشاكل الـ Casting بين int و double
    var landmarksList = json["landmarks"] as List? ?? [];
    
    List<List<double>> parsedFrames = landmarksList.map<List<double>>((frame) {
      if (frame is List) {
        return frame.map<double>((value) => (value as num).toDouble()).toList();
      }
      return [];
    }).toList();

    return AvatarSign(
      word: json["word"] ?? "",
      avatarLabelIndex: json["avatar_label_index"] ?? 0,
      frames: json["frames"] ?? 0,
      landmarksPerFrame: json["landmarks_per_frame"] ?? 0,
      landmarks: parsedFrames,
    );
  }
}