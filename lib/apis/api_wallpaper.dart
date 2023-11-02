import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/env/env.dart';

import '../models/wallpaper.dart';

/// Api for displaying wallpapers for phones and tablets
class ApiServiceWallpaper {
  final urlLogin = "https://wallpapers-api.onrender.com/login";
  final urlWallpapers = "https://wallpapers-api.onrender.com/wallpapers";
  final urlWallpapersTablet =
      "https://wallpapers-api.onrender.com/wallpapersTablet";
  Response? jsonResponse, tokenResponse;

  /// POST Request to login in the API, GET Request to the api

  Future<List<Wallpaper>> getWallpapers(bool isTablet) async {
    try {
      tokenResponse = await http.post(Uri.parse(urlLogin),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{'email': Env.email, 'password': Env.password}));
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      //exit(0);
    }

    Map<String, dynamic>? responseToken = jsonDecode(tokenResponse!.body);
    if (!responseToken!.containsKey("token")) {
      sendErrorMail(false, "ERROR", "ERROR NEWS ${responseToken["detail"]}");
      return List.empty();
    }
    String token = responseToken["token"];
    if (isTablet) {
      jsonResponse = await http.get(Uri.parse(urlWallpapersTablet),
          headers: {'Authorization': 'Bearer $token'});
    } else {
      jsonResponse = await http.get(Uri.parse(urlWallpapers), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    }

    Map<String, dynamic>? json;
    try {
      json = convert.jsonDecode(jsonResponse!.body);
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      //exit(0);
    }

    if (!json!.containsKey("wallpapers")) {
      sendErrorMail(false, "ERROR", "ERROR WALLPAPER ${json["detail"]}");
      return List.empty();
    }
    List<dynamic> body = json["wallpapers"];
    List<Wallpaper> wallpapers =
        body.map((dynamic item) => Wallpaper.fromJson(item)).toList();

    wallpapers = wallpapers.reversed.toList();
    return wallpapers;
  }
}
