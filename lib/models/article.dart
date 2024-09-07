/// Model used for structuring the API response with all the required fields.
class Article {
  String title;
  String description;
  String url;
  String date;
  String type;
  String image;
  Article({
    required this.title,
    required this.description,
    required this.url,
    required this.date,
    required this.type,
    required this.image,
  });
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
        title: json['title'] == null ? '' : json['title'] as String,
        description:
            json['description'] == null ? '' : json['description'] as String,
        url: json['source'] as String,
        date: json['date'] != null ? json['date'] as String : "",
        type: json['types'] == null ? '' : json['types'].toString(),
        image: json['image'] == null ? '' : json['image'].toString());
  }
}
