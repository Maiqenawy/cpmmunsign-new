class AvatarSign {
  final String word;
  final List<List<double>> landmarks;

  AvatarSign({
    required this.word,
    required this.landmarks,
  });

  int get framesCount => landmarks.length;

  factory AvatarSign.fromJson(Map<String, dynamic> json) {
    return AvatarSign(
      word: json["word"],
      landmarks: (json["landmarks"] as List)
          .map<List<double>>(
            (e) => List<double>.from(e),
          )
          .toList(),
    );
  }
}