import 'dart:io';
import 'dart:isolate';
import 'package:book_tracker/models/book_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/utils.dart';

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

// used so that images can be found from image url by gridview builder. Does not store null urls
final urlToFilePathLookup = StateProvider<Map<String, Future<String?>>>((ref) => {});
final tempDirProvider = FutureProvider<Directory>((ref) async => await getTemporaryDirectory());
// Should send a request to the server for the query and the page, and return the response body.
// (There will be some duplicate listings of works (ie multiple Harry Potter sorcerer's stone)
// Because the API has so many, but just pick the one you wish and make your search more specific to find the one you want)
// TODO: Depending on speed, may make this concurrent with multiple providers to push to for now just 1.
// TODO: Change chunk size from 12 -> 28. Make this reliant on a chunkSize global provider.
Future<void> fetchBooks({required String query, required String page, required WidgetRef ref}) async {
  debugPrint("Starting...");
  final url = Uri.https(
      "openlibrary.org",
      "/search.json",
      {
        "q" : query,
        "fields" : "title author_name publish_year cover_edition_key",
        "limit" : "200", // How many results to show per page. Higher is better so less fetches required per result
        "page": page
      }
  );
  print(url.toString());
  try {
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      debugPrint("Success");
      // write to temp file
      storeResponse(response: resp.body, ref: ref);
    } else {
      debugPrint("Failure code ${resp.statusCode}");
    }
  } catch (e) {
    debugPrint("Error: $e");
  }

}

Future<void> storeResponse({required String response, required WidgetRef ref}) async {
  final tempDir = ref.watch(tempDirProvider).value;
  // Create a new directory if it's not there. Or if it is then it is overwritten as fresh
  final newDir = Directory("${tempDir!.path}/latestResponse");
  await newDir.create(recursive: false);
  // Next, map out the "docs" (books) portion of the response and split it into chunks (max 12 entries per)
  final Map<String, dynamic> json = jsonDecode(response);
  final docs = json['docs'] as List<dynamic>;
  // must make "s surrounding the keys and values explicit to be parsed as JSON later.
  final edited = docs.map((book) => book.map((key, value) => MapEntry('\"$key\"', '\"$value\"')));
  final chunkedDocs = chunkList(list: edited.toList(), maxEntries: 12);
  // Next, write the chunks to disk
  for (int i = 0; i < chunkedDocs.length; i++) {
    final chunk = chunkedDocs[i];
    final file = File("${newDir.path}/chunk_${i+1}.json");
    file.writeAsString(chunk.toString());
  }
}







