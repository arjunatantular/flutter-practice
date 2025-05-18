// Model that should come out of parsing response data.
// Response -> Model (parsed) -> UI (loaded)
// TODO: Create a factory method here from JSON (pass parser in)
class BookData {
  final String? title; // At this point just be prepared for no data
  final String? authorName; // Rare, but some books will not have this data
  final String? publishDate; // Rare, but some books will not have this data
  final String? coverImageUrl; // Some books will not have this data
  BookData({
    required this.title,
    required this.authorName,
    required this.publishDate,
    required this.coverImageUrl
  });

factory BookData.fromJson(Map<String, dynamic> json) {
  // To fetch image: https://covers.openlibrary.org/b/$key/$value-$size.jpg
  // (Small, Medium, or Large)
  final String? key = json['cover_edition_key'];
  return BookData(
      title: json['title'],
      authorName: json['author_name'],
      publishDate: json['publish_year'][0],
      coverImageUrl: key == null
          ? null
          : "https://covers.openlibrary.org/b/olid/$key-M.jpg"
  );}
}



