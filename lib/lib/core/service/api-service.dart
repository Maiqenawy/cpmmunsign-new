import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Service {
  static const String baseUrl = "http://cominisign.runasp.net/api";

  static String token = "";

  static Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  static Map<String, String> headersWithAuth() {
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ================= REGISTER =================
 static Future register({
  required String name,
  required String email,
  required String password,
  required String confirmPassword,
  required String address,
}) async {
  try {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/register"),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
        "address": address,
      }),
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final data = jsonDecode(response.body);

      // لو السيرفر بيرجع errors
      if (data is Map && data.containsKey("errors")) {
        final errors = data["errors"];
        return Future.error(errors.toString());
      }

      return Future.error(data["message"] ?? "Register failed");
    }
  } on SocketException {
    return Future.error("No internet connection");
  } catch (e) {
  print("ERROR: $e");
  return Future.error(e.toString());
}
  // ================= LOGIN =================
  static Future login({
    required String email,
    required String password,
  }) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/login"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      token = data["token"];
      return data;
    } else {
      throw Exception("Login failed");
    }
  }

  // ================= FORGOT PASSWORD =================
  static Future forgotPassword(String email) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/forgot-password"),
      headers: headers,
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Failed to send email");
    }
  }

  // ================= RESET PASSWORD =================
  static Future resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/reset-password"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "token": token,
        "newPassword": newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Reset failed");
    }
  }

  // ================= CONTACTS =================
  static Future<List> getContacts(String token) async {
    var res = await http.get(
      Uri.parse("$baseUrl/contact"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future addContact(int userId, String relation, String token) async {
    await http.post(
      Uri.parse("$baseUrl/contact"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "contactUserId": userId,
        "relation": relation,
      }),
    );
  }

  static Future updateContact(int contactId, String relation, String token) async {
    await http.put(
      Uri.parse("$baseUrl/contact/$contactId"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "relation": relation,
      }),
    );
  }

  static Future deleteContact(int contactId, String token) async {
    await http.delete(
      Uri.parse("$baseUrl/contact/$contactId"),
      headers: headersWithAuth(),
    );
  }

  static Future<List> searchUser(String email, String token) async {
    var res = await http.get(
      Uri.parse("$baseUrl/contact/search?email=$email"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  // ================= SETTINGS =================
  static Future<Map> getSettings() async {
    var res = await http.get(
      Uri.parse("$baseUrl/settings"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future updateSettings({
    required bool darkMode,
    required String language,
    required String avatarName,
  }) async {
    await http.put(
      Uri.parse("$baseUrl/settings"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "darkMode": darkMode,
        "language": language,
        "avatarName": avatarName,
      }),
    );
  }

  // ================= EMERGENCY =================
  static Future<List> getPictograms() async {
    var res = await http.get(
      Uri.parse("$baseUrl/emergency/pictograms"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  // ✅ FIXED sendSOS (NO duplicate location)
  static Future sendSOS({
    required int pictogramId,
    required String location,
  }) async {
    await http.post(
      Uri.parse("$baseUrl/emergency/send-sos/$pictogramId"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "location": location,
      }),
    );
  }

  // ================= FIREBASE TOKEN =================
  static Future updateDeviceToken(String fcmToken) async {
    await http.post(
      Uri.parse("$baseUrl/account/update-device-token"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "fcmToken": fcmToken,
      }),
    );
  }

  // ================= LEARNING =================
  static Future<List> getLevels() async {
    var res = await http.get(
      Uri.parse("$baseUrl/learning/levels"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future<List> getUserLevels() async {
    var res = await http.get(
      Uri.parse("$baseUrl/learning/user-levels"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future<List> getWordsWithProgress(int levelId) async {
    var res = await http.get(
      Uri.parse("$baseUrl/learning/words-with-progress/$levelId"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future<Map> updateProgress(int wordId) async {
    var res = await http.post(
      Uri.parse("$baseUrl/learning/progress"),
      headers: headersWithAuth(),
      body: jsonEncode({
        "learningWordId": wordId,
      }),
    );

    return jsonDecode(res.body);
  }

  static Future<Map> checkLevelCompletion(int levelId) async {
    var res = await http.get(
      Uri.parse("$baseUrl/learning/check-level-completion/$levelId"),
      headers: headersWithAuth(),
    );

    return jsonDecode(res.body);
  }

  static Future unlockNextLevel(int levelId) async {
    await http.post(
      Uri.parse("$baseUrl/learning/unlock-next-level/$levelId"),
      headers: headersWithAuth(),
    );
  }

  // ================= TEXT TO SIGNS =================
  static Future<List<String>> textToSigns(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ai/text-to-signs"),
      headers: headers,
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
    return List<String>.from(data["Signs"] ?? []);
    } else {
      throw Exception("Translation failed");
    }
  }

  // ================= SIGN TO TEXT =================
  static Future<String> signToText(File image) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/ai/sign-to-text"),
    );

    request.files.add(
      await http.MultipartFile.fromPath("Frame", image.path),
    );

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["text"];
    } else {
      throw Exception("AI prediction failed");
    }
  }
}
