import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/env/env.dart';

import '../models/article.dart';

/// Api for displaying news
class ApiServiceNews {
  final urlLogin = "https://news-api-2t91.onrender.com/login";
  final urlNews = "https://news-api-2t91.onrender.com/news";

  /// POST Request to login in the API, and then a GET Request in order to get the latest news using private API
  Future<List<Article>> getNews() async {
    Response? tokenResponse;
    Response? jsonResponse;
    try {
      tokenResponse = await http.post(Uri.parse(urlLogin),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{'email': Env.email, 'password': Env.password}));
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      exit(0);
    }

    Map<String, dynamic>? responseToken = jsonDecode(tokenResponse.body);
    if (!responseToken!.containsKey("token")) {
      sendErrorMail(false, "ERROR", "ERROR NEWS ${responseToken["detail"]}");
      return List.empty();
    }
    String token = responseToken["token"];

    try {
      jsonResponse = await http.get(Uri.parse(urlNews), headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      exit(0);
    }

    Map<String, dynamic>? json;
    try {
      json = convert.jsonDecode(jsonResponse.body);
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      exit(0);
    }
    print(json);
    if (!json!.containsKey("news")) {
      sendErrorMail(false, "ERROR", "ERROR NEWS " + json["detail"]);
      return List.empty();
    }
    List<dynamic> body = json['news'];
    List<Article> news =
        body.map((dynamic item) => Article.fromJson(item)).toList();

    news = news.toList();
    return news;
  }
}
