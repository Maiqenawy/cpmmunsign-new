import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cominsign_new/core/user_session.dart';
import 'package:cominsign_new/screens/avatar_sign_model.dart';

class Service {
  static const String baseUrl = "https://cominisign.runasp.net/api";

  static String token = "";

  static Map<String, String> headers = {"Content-Type": "application/json"};

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

      // ✅ الحل: تحويل البودي لنص صريح قبل الفحص
      String resBody = response.body;

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (resBody.isEmpty) return {};
        var data = jsonDecode(resBody);

        if (data is Map && data["token"] != null) {
          token = data["token"];
          UserSession.token = data["token"];
        }
        return data;
      } else {
        // التعامل مع أخطاء السيرفر
        String errorMsg = "Registration failed";
        if (resBody.isNotEmpty) {
          try {
            var errorData = jsonDecode(resBody);
            errorMsg = errorData['message'] ?? errorMsg;
          } catch (_) {}
        }
        throw errorMsg;
      }
    } catch (e) {
      rethrow;
    }
  }

  // ================= LOGIN =================
  static Future login({required String email, required String password}) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/login"),
      headers: headers,
      body: jsonEncode({"email": email, "password": password}),
    );

    String responseBody = response.body;

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = jsonDecode(responseBody);
      token = data["token"] ?? "";
      UserSession.token = token; // مزامنة التوكن مع الجلسة
      return data;
    } else {
      throw Exception("Login failed: $responseBody");
    }
  }

  // ================= FORGOT PASSWORD =================
  static Future forgotPassword(String email) async {
  var response = await http.post(
    Uri.parse("$baseUrl/Account/forgot-password"),
    headers: headers,
    body: jsonEncode({"email": email}),
  );

  print("Status Code: ${response.statusCode}");
  print("Response Body: ${response.body}");

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception(response.body);
  }
}

  // ================= RESET PASSWORD =================
  static Future resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Account/reset-password"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "code": code,
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
  static Future<List> getContacts() async {
    var res = await http.get(
      Uri.parse("$baseUrl/contact"),
      headers: headersWithAuth(),
    );

    String responseBody = res.body;
    if (responseBody.isEmpty) return [];
    return jsonDecode(responseBody);
  }

  static Future addContact({
    required String name,
    required String email,
    required String relation,
  }) async {
    var res = await http.post(
      Uri.parse("$baseUrl/contact"),
      headers: headersWithAuth(),
      body: jsonEncode({"name": name, "email": email, "relation": relation}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception("Failed to add contact");
    }
  }

  static Future updateContact({
    required int contactId,
    required String name,
    required String email,
    required String relation,
  }) async {
    var res = await http.put(
      Uri.parse("$baseUrl/contact/$contactId"),
      headers: headersWithAuth(),
      body: jsonEncode({"name": name, "email": email, "relation": relation}),
    );

    if (res.statusCode != 200) {
      throw Exception("Update failed");
    }
  }

  static Future deleteContact(int contactId) async {
    await http.delete(
      Uri.parse("$baseUrl/contact/$contactId"),
      headers: headersWithAuth(),
    );
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

  static Future sendSOS({
    required int pictogramId,
    required String location,
  }) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Emergency/send-sos/$pictogramId"),
      headers: headersWithAuth(),
      body: jsonEncode({"location": location}),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to send SOS");
    }
  }

  // ================= CHAT =================
  static Future<String> chat(String message) async {
    var response = await http.post(
      Uri.parse("$baseUrl/Chat"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${UserSession.token}",
      },
      body: jsonEncode({"message": message}),
    );

    String responseBody = response.body;
    if (responseBody.isEmpty) {
      throw Exception("Empty response");
    }

    if (response.statusCode == 200) {
      var data = jsonDecode(responseBody);
      return data["reply"];
    } else {
      throw Exception("Chat failed");
    }
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
      body: jsonEncode({"learningWordId": wordId}),
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

  // ================= AI: TEXT → SIGNS =================

  static Future<List<AvatarSign>> textToSigns(String text) async {
    final response = await http.post(
      Uri.parse("$baseUrl/ai/text-to-signs"),
      headers: headers,
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // الباك بيرجع List مباشرة
      return (data as List).map((e) => AvatarSign.fromJson(e)).toList();
    } else {
      throw Exception("Translation failed");
    }
  }
static Future<AvatarSign> wordToSign(int wordId) async {
  final response = await http.post(
    Uri.parse("$baseUrl/ai/word-to-sign"),
    headers: headers,
    body: jsonEncode({
      "wordId": wordId,
    }),
  );

  debugPrint("========== WORD TO SIGN ==========");
  debugPrint("WORD ID = $wordId");
  debugPrint("STATUS = ${response.statusCode}");
  debugPrint("BODY = ${response.body}");
  debugPrint("==================================");

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return AvatarSign.fromJson(data);
  } else {
    throw Exception(
      "Word to sign failed | Status: ${response.statusCode} | Body: ${response.body}",
    );
  }
}
  // ================= AI: SIGN → TEXT =================
  static Future<String> signToText(File image) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/ai/sign-to-text"),
    );

    request.files.add(await http.MultipartFile.fromPath("Frame", image.path));

    var response = await request.send();
    var res = await http.Response.fromStream(response);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data["text"];
    } else {
      throw Exception("AI prediction failed");
    }
  }

  // ================= AI: REALTIME FRAMES =================

  static Future<String> sendFrames(List<List<double>> frames) async {
    final response = await http.post(
      Uri.parse(
        "https://sign-language-api-production-2148.up.railway.app/predict",
      ),
      headers: headers,
      body: jsonEncode({"sequence": frames}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.toString();
    } else {
      throw Exception("Real-time prediction failed: ${response.body}");
    }
  }
}

