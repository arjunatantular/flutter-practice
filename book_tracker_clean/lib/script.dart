import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

void main() {
  final resp = requestBooks(query: "title:Harry Potter AND author_name:JK Rowling", page: 1);
  print(resp);
}

// Takes in query, page number, gets result from server and writes response body to disk (chunks are 12 books max each)
/*
Max chunk size is 12, since the whole fetch -> parse -> render thing, we want 2
screens in the future when we're near the bottom, approx. 4 books per screen + a little cushion
= we should get data for 12 books

TempResponseDirectory
- chunk_1 (books #0 to 11)
- chunk_2 (books 12 to 23)
- chunk_3 (books 24 to 30) (capped out, only 30 results given)

 */
Future<void> fetchBooks() async{
  // TODO: Bring functions together. Or, if you think it's more simple, rewrite them so this central function isn't needed.
}



// Should send a request to the server for the query and the page, and return the response body.
// (There will be some duplicate listings of works (ie multiple Harry Potter sorcerer's stone)
// Because the API has so many, but just pick the one you wish and make your search more specific to find the one you want)
// TODO: Depending on speed, may make this concurrent with multiple providers to push to for now just 1.
Future<String> requestBooks({required String query, required int page}) async {
  // should send result to riverpod (null if error)
  print("Starting...");
  final url = Uri.https(
      "openlibrary.org",
      "/search.json",
      {
        "q" : query,
        "fields" : "title author_name publish_year cover_edition_key",
        "limit" : 200, // How many results to show per page. Higher is better so less fetches required per result
        "page": page
      }
  );
  try {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      print("Success: ${resp.body}");
      // write to temp file
      return resp.body;
    } else {
      print("Failure code ${resp.statusCode}");
      return "Failure code ${resp.statusCode}";
    }
  } catch (e) {
    print("Error: $e");
    return "Error: $e";
  }

}

// TODO: Organize these in a .util file later
// Write to temp directory as described before.
/*
Max chunk size is 12, since the whole fetch -> parse -> render thing, we want 2
screens in the future when we're near the bottom, approx. 4 books per screen + a little cushion
= we should get data for 12 books

TempResponseDirectory
- chunk_1 (books #0 to 11)
- chunk_2 (books 12 to 23)
- chunk_3 (books 24 to 30) (capped out, only 30 results given)
 */
Future<void> storeResponse(String response) async {
  final tempDir = await getTemporaryDirectory();
  // Create a response directory with chunks for your parser to loop (length = 12 max)
  final newDir = Directory("$tempDir/latestResponse");
  await newDir.create(recursive: false);
  // Next, using the "docs" (books) portion of the response, turn this into a


  final file = File("$newDir/resp.json");
  file.writeAsString(response);
}

Future<String> readResponse() async {
  final tempDir = await getTemporaryDirectory();
  final file = File("$tempDir/latestResponse/resp.json");
  return file.readAsString();
}

// To fetch image: https://covers.openlibrary.org/b/$key/$value-$size.jpg
// (Small, Medium, or Large)