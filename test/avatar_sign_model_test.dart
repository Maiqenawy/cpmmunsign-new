import 'package:flutter_test/flutter_test.dart';
import 'package:cominsign_new/screens/avatar_sign_model.dart';

void main() {
group('AvatarSign.fromJson Tests', () {
  test('should parse nested list landmarks (2D)', () {
    final json = {
      "word": "eat",
      "landmarks": [
        [1.0, 2.0, 3.0],
        [4.0, 5.0, 6.0]
      ]
    };

    final avatarSign = AvatarSign.fromJson(json);

    expect(avatarSign.word, "eat");
    expect(avatarSign.framesCount, 2);
    expect(avatarSign.landmarks[0], [1.0, 2.0, 3.0]);
    expect(avatarSign.landmarks[1], [4.0, 5.0, 6.0]);
  });

  test('should parse flat list landmarks using frames and landmarks_per_frame', () {
    final json = {
      "word": "eat",
      "frames": 2,
      "landmarks_per_frame": 3,
      "landmarks": [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    };

    final avatarSign = AvatarSign.fromJson(json);

    expect(avatarSign.word, "eat");
    expect(avatarSign.framesCount, 2);
    expect(avatarSign.landmarks[0], [1.0, 2.0, 3.0]);
    expect(avatarSign.landmarks[1], [4.0, 5.0, 6.0]);
  });

  test('should fallback if frames is missing but landmarks_per_frame is present', () {
    final json = {
      "word": "eat",
      "landmarks_per_frame": 3,
      "landmarks": [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
    };

    final avatarSign = AvatarSign.fromJson(json);

    expect(avatarSign.word, "eat");
    expect(avatarSign.framesCount, 2);
    expect(avatarSign.landmarks[0], [1.0, 2.0, 3.0]);
    expect(avatarSign.landmarks[1], [4.0, 5.0, 6.0]);
  });

  test('should handle empty landmarks list', () {
    final json = {
      "word": "eat",
      "landmarks": []
    };

    final avatarSign = AvatarSign.fromJson(json);

    expect(avatarSign.word, "eat");
    expect(avatarSign.landmarks, isEmpty);
  });
});
}
