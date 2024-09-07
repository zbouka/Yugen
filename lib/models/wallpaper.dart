/// Model used for structuring the API response with all the required fields.
class Wallpaper {
  String title;
  String wallpaper;
  String resolution;
  Wallpaper({
    required this.title,
    required this.wallpaper,
    required this.resolution,
  });
  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
      title: json['title'] == null ? '' : json['title'] as String,
      wallpaper: json['wallpaper'] as String,
      resolution:
          json['resolution'] == null ? '' : json['resolution'] as String,
    );
  }
}
