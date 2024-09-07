import 'dart:convert' as convert;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:yugen/apis/email.dart';
import 'package:yugen/env/env.dart';
import '../models/article.dart';

/// ApiServiceNews: API for displaying news
class ApiServiceNews {
  final String urlLogin = "https://news-api-2t91.onrender.com/login";
  final String urlNews = "https://news-api-2t91.onrender.com/news";

  /// Fetches the latest news using the private API
  Future<List<Article>> getNews() async {
    try {
      // Fetch token from API
      String? token = await _fetchToken();
      if (token == null) return List.empty();

      // Fetch news using the token
      final jsonResponse = await _fetchNews(token);
      if (jsonResponse == null) return List.empty();

      // Parse the news articles
      return _parseNews(jsonResponse);
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
        body: convert.jsonEncode({
          'email': Env.email,
          'password': Env.password,
        }),
      );

      if (tokenResponse.statusCode != 200) {
        await sendErrorMail(
            false, "ERROR", "Login failed: ${tokenResponse.body}");
        return null;
      }

      final Map<String, dynamic> responseToken =
          convert.jsonDecode(tokenResponse.body);
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

  /// Fetches news using the provided token
  Future<Response?> _fetchNews(String token) async {
    try {
      final response = await http.get(
        Uri.parse(urlNews),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode != 200) {
        await sendErrorMail(
            false, "ERROR", "Failed to fetch news: ${response.body}");
        return null;
      }

      return response;
    } catch (e) {
      await sendErrorMail(false, "ERROR", e);
      return null;
    }
  }

  /// Parses the news data from the API response
  List<Article> _parseNews(Response jsonResponse) {
    try {
      final Map<String, dynamic> json =
          convert.jsonDecode(utf8.decode(jsonResponse.bodyBytes));

      if (!json.containsKey("news")) {
        sendErrorMail(
            false, "ERROR", "News key missing in response: ${json["detail"]}");
        return List.empty();
      }

      List<dynamic> body = json['news'];
      return body.map((dynamic item) => Article.fromJson(item)).toList();
    } catch (e) {
      sendErrorMail(false, "ERROR", e);
      return List.empty();
    }
  }
}
