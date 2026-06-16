class AvatarSign {
  final String word;
  final int frames;
  final List<List<double>> landmarks;

  AvatarSign({
    required this.word,
    required this.frames,
    required this.landmarks,
  });

  factory AvatarSign.fromJson(
    Map<String, dynamic> json,
  ) {
    return AvatarSign(
      word: json["word"],

      frames: json["frames"],

      landmarks:
          (json["landmarks"] as List)
              .map<List<double>>(
                (e) => List<double>.from(e),
              )
              .toList(),
    );
  }
}
