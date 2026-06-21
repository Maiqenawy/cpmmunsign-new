class AvatarSign {
  final String word;
  final List<List<double>> landmarks;

  AvatarSign({
    required this.word,
    required this.landmarks,
  });

  int get framesCount => landmarks.length;

  factory AvatarSign.fromJson(Map<String, dynamic> json) {
    final String word = json["word"] ?? "";
    final rawLandmarks = json["landmarks"];
    List<List<double>> nestedLandmarks = [];

    if (rawLandmarks is List) {
      if (rawLandmarks.isEmpty) {
        nestedLandmarks = [];
      } else if (rawLandmarks.first is List) {
        nestedLandmarks = rawLandmarks
            .map<List<double>>(
              (frame) => (frame as List)
                  .map((x) => (x as num).toDouble())
                  .toList(),
            )
            .toList();
      } else {
        // It's a flat list of numbers (1D)
        final flatList = rawLandmarks.map((x) => (x as num).toDouble()).toList();
        final int framesCount = json["frames"] ?? 0;
        final int landmarksPerFrame = json["landmarks_per_frame"] ?? 258;

        if (framesCount > 0 && landmarksPerFrame > 0) {
          for (int i = 0; i < framesCount; i++) {
            final int start = i * landmarksPerFrame;
            final int end = start + landmarksPerFrame;
            if (end <= flatList.length) {
              nestedLandmarks.add(flatList.sublist(start, end));
            } else if (start < flatList.length) {
              nestedLandmarks.add(flatList.sublist(start));
            }
          }
        } else if (landmarksPerFrame > 0) {
          for (int i = 0; i < flatList.length; i += landmarksPerFrame) {
            final int end = i + landmarksPerFrame;
            if (end <= flatList.length) {
              nestedLandmarks.add(flatList.sublist(i, end));
            } else {
              nestedLandmarks.add(flatList.sublist(i));
            }
          }
        } else {
          nestedLandmarks = [flatList];
        }
      }
    }

    return AvatarSign(
      word: word,
      landmarks: nestedLandmarks,
    );
  }
}