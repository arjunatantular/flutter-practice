// Model that should come out of parsing response data.
// Response -> Model (parsed) -> UI (loaded)
// TODO: Create a factory method here from JSON (pass parser in)
import 'dart:convert';

class BookData {
  final String? title; // Rare, but some books will not have this data
  final String? authorName; // Rare, but some books will not have this data
  final String? publishDate; // Rare, but some books will not have this data
  final String? coverImageUrl; // Some books will not have this data
  BookData({
    required this.title,
    required this.authorName,
    required this.publishDate,
    required this.coverImageUrl
  }) {
    print("Created BookData with values:");
    print("Title:$title\nauthorName:$authorName\npublishDate:$publishDate\ncoverImageUrl:$coverImageUrl");
  }

factory BookData.fromJson(Map<String?, String?> json) {
  // If you have ["J.K. Rowling", "Ted Freecs", ..."] try to get the first entry. If it is null return null.
  String? getFirstJsonStringList(String? rawList) {
    // rawList: "[J.K. rowling, JK ROWLING, ...]". Just turn this into a list
    // If it is null or there's not more length than [], there's nothing in there.
    if (rawList == null || rawList.length <= 2) return null;
    final List<String> list = rawList.substring(1, rawList.length-1)
        .split(", ");
    return list[0];
  }
  // To fetch image: https://covers.openlibrary.org/b/$key/$value-$size.jpg
  // (Small, Medium, or Large)
  final String? key = json['cover_edition_key'];
  return BookData(
      title: json['title'],
      authorName: getFirstJsonStringList(json['author_name']), // usually comes in a list
      publishDate: getFirstJsonStringList(json['publish_year']),
      coverImageUrl: key == null
          ? null
          : "https://covers.openlibrary.org/b/olid/$key-M.jpg"
  );}


}



