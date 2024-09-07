import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yugen/apis/email.dart';
import 'package:yugen/env/env.dart';
import '../models/wallpaper.dart';

/// API Service for fetching wallpapers for phones and tablets
class ApiServiceWallpaper {
  final String urlLogin = "https://wallpapers-api.onrender.com/login";
  final String urlWallpapers = "https://wallpapers-api.onrender.com/wallpapers";
  final String urlWallpapersTablet =
      "https://wallpapers-api.onrender.com/wallpapersTablet";

  /// Fetches wallpapers based on the device type (tablet or phone)
  Future<List<Wallpaper>> getWallpapers(bool isTablet) async {
    try {
      // Fetch token first
      String? token = await _fetchToken();
      if (token == null) {
        return List.empty();
      }

      // Select the correct URL based on the device type
      String url = isTablet ? urlWallpapersTablet : urlWallpapers;

      // Fetch wallpapers
      final jsonResponse = await _getWallpapers(token, url);
      if (jsonResponse == null) return List.empty();

      // Parse the response
      return _parseWallpapers(jsonResponse);
    } catch (e) {
      await sendErrorMail(false, "ERROR", e);
      return List.empty();
    }
  }

  /// Fetches the authentication token by logging in
  Future<String?> _fetchToken() async {
    try {
      final tokenResponse = await http.post(
        Uri.parse(urlLogin),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': Env.email, 'password': Env.password}),
      );

      if (tokenResponse.statusCode != 200) {
        await sendErrorMail(
            false, "ERROR", "Login failed: ${tokenResponse.body}");
        return null;
      }

      final Map<String, dynamic> responseToken = jsonDecode(tokenResponse.body);
      if (!responseToken.containsKey("token")) {
        await sendErrorMail(
            false, "ERROR", "Token not found: ${responseToken["detail"]}");
        return null;
      }

      return responseToken["token"];
    } catch (e) {
      await sendErrorMail(false, "ERROR", e);
      return null;
    }
  }

  /// Fetches wallpapers using the provided token and URL
  Future<http.Response?> _getWallpapers(String token, String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        await sendErrorMail(
            false, "ERROR", "Failed to fetch wallpapers: ${response.body}");
        return null;
      }

      return response;
    } catch (e) {
      await sendErrorMail(false, "ERROR", e);
      return null;
    }
  }

  /// Parses the wallpaper data from the response
  List<Wallpaper> _parseWallpapers(http.Response jsonResponse) {
    try {
      final Map<String, dynamic> json = convert.jsonDecode(jsonResponse.body);

      if (!json.containsKey("wallpapers")) {
        sendErrorMail(false, "ERROR",
            "Wallpapers key missing in response: ${json["detail"]}");
        return List.empty();
      }

      List<dynamic> wallpapersData = json["wallpapers"];
      List<Wallpaper> wallpapers =
          wallpapersData.map((item) => Wallpaper.fromJson(item)).toList();

      return wallpapers.reversed.toList(); // Return reversed list
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      return List.empty();
    }
  }
}
