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

// used so that images can be found from image url by gridview builder
final urlToFilePathLookup = StateProvider<Map<String?, String?>>((ref) => {});
final tempDirProvider = FutureProvider<Directory>((ref) async => await getTemporaryDirectory());
// Should send a request to the server for the query and the page, and return the response body.
// (There will be some duplicate listings of works (ie multiple Harry Potter sorcerer's stone)
// Because the API has so many, but just pick the one you wish and make your search more specific to find the one you want)
// TODO: Depending on speed, may make this concurrent with multiple providers to push to for now just 1.
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


// Make tempDir a global variable via a provider so that this doesn't have to be async and it can be called by the parser factory.
Future<List<Map<String, String?>>> getChunkJson({required int chunk, required WidgetRef ref}) async {
  final tempDir = ref.watch(tempDirProvider).value;
  //print(tempDir!.path);
  final chunkFile = File("${tempDir!.path}/latestResponse/chunk_$chunk.json");
  final jsonText = await chunkFile.readAsString();
  final json = ((jsonDecode(jsonText) as List)
      .map((entry) => (entry as Map)
      .map((key, value) => MapEntry(key as String, value as String?))))
      .toList();
  return json;
  // i think theres a casting error here. test it.
}

// TODO: Be able to pass in the filters data (author name, publication date, work name, etc.) and return a string for the query to pass into the sendRequest function.
String filterDataToQuery() {
  return "";
}

// TODO: This is here temporarily. will be adapted into one buffer class later
// Isolates are definitely overkill here but good practice using them:
Future<List<BookData>> parseChunk(int number, WidgetRef ref) async {
  final rawList = (await getChunkJson(chunk: 1, ref: ref) as List)
      .cast<Map<String, String?>>();
  final List<BookData> bookList = rawList
      .map((json) => BookData.fromJson(json))
      .toList();
  final List<String> urlList = [];
  // initialize urlList
  // don't include any null links (if you can't locate your key here consider the image null
  for(var book in bookList) {
    if (book.coverImageUrl == null) continue;
    urlList.add(book.coverImageUrl!);
    // initialize lookup table
    ref.read(urlToFilePathLookup.notifier)
        .state[book.coverImageUrl] = null;
  }
  // clear any previous data
  ref.read(urlToFilePathLookup.notifier).state.clear();
  // begin isolate to begin downloading files
  final updatedLookup = await Isolate.run(() {
    return downloadImages(
        urlList,
        ref.watch(tempDirProvider).value);
  });
  // update lookup table
  ref.read(urlToFilePathLookup.notifier).state = Map.from(updatedLookup);
  return bookList;
}

// TODO: Figure out the correct types here. Pretty sure it should be String? String?
// you must pass in only urls, no non urls. If there is a null url obviously there will be no file.
// so when you go to fetch a filepath from the returned map, if you can't find it consider it null.
// a return type of Map<String String?> is required because if you do have a url there still may be an error trying to fetch.
Future<Map<String, String?>> downloadImages(List<String> urlList, Directory? tempDir) async {
  // filepath (the value) will be null if there was an error trying to get it.
  // url : filepath of downloaded image
  final Map<String, String?> temp = {};
  // before you begin, create / clear the image directory:
  final newDir = Directory("${tempDir!.path}/coverImages");
  await newDir.create(recursive: false);
  for (var url in urlList) {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) { // success
      // Create new unique file, write image bytes:
      // example: 'https://covers.openlibrary.org/a/olid/OL23919A-M.jpg'
      final imgCode = url.split("olid/")[1];
      final file = File("${newDir.path}/$imgCode");
      await file.writeAsBytes(response.bodyBytes);
      // update temp map
      temp[url] = "${newDir.path}/$imgCode";
    } else { // failure
      // update temp map
      temp[url] = null;
    }
  }
  return temp;
}




