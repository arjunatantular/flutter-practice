// Model that should come out of parsing response data.
// Response -> Model (parsed) -> UI (loaded)
// TODO: Create a factory method here from JSON (pass parser in)
class BookData {
  final String title;
  final String authorName;
  final String publishDate;
  final String coverImageUrl;
  BookData({
    required this.title,
    required this.authorName,
    required this.publishDate,
    required this.coverImageUrl
  });
}



