import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;

// newest response body
final newRespBody = StateProvider<String>((ref) => "empty");

// TODO: Write this to a temporary file using getTempDir(). You can pull from there to trsr too.
// TODO: May or may not make this concurrent with multiple providers to push to if speed is too alow, for now just 1.
Future<void> fetchBooks({required String query, required Ref ref}) async {
  // should send result to riverpod (null if error)
  print("Starting...");
  final url = Uri.https(
      "openlibrary.org",
      "/search.json",
      {
        "q" : query,
        "page": "2"
      }
  );
  try {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      print("Success: ${resp.body}");
      ref.watch(newRespBody.notifier).state = resp.body;
    } else {
      print("Failure code ${resp.statusCode}");
    }
  } catch (e) {
    print("Error: $e");
  }

}