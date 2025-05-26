import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fetch_data.dart';
import 'dart:convert';
import 'dart:io';
import 'package:book_tracker/models/book_data.dart';
import 'dart:isolate';
import 'package:http/http.dart' as http;

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
// TODO: Coming back? Trying to fix the book_data factory method and parsing that stuff.
// returns filepath for image when done downloading or null if error
Future<String?> downloadImage({required String url, required String imageDir}) async {
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) { // success
    // Create new unique file, write image bytes:
    // example: 'https://covers.openlibrary.org/a/olid/OL23919A-M.jpg'
    final imgCode = url.split("olid/")[1];
    final file = File("$imageDir/$imgCode");
    await file.writeAsBytes(response.bodyBytes);
    return "$imageDir/$imgCode";
  } else { // failure
    return null;
  }
}

// TODO: This is here temporarily. will be adapted into one buffer class later
Future<List<BookData>> parseChunk(int number, WidgetRef ref) async {
  final rawList = (await getChunkJson(chunk: 1, ref: ref) as List)
      .cast<Map<String, String?>>();
  final List<BookData> bookList = rawList
      .map((json) => BookData.fromJson(json))
      .toList();
  final List<String> urlList = [];
  for (var book in bookList) {
    if (book.coverImageUrl == null) continue;
    urlList.add(book.coverImageUrl!);
  }
  // initialize lookup table
  // clear any previous data
  ref
      .read(urlToFilePathLookup.notifier)
      .state
      .clear();
  // begin isolate to begin downloading files
  final path = ref
      .watch(tempDirProvider)
      .value!
      .path
      .toString();
  final imageDir = Directory("$path/coverImages"); // create + clear dir
  await imageDir.create(recursive: false);
  print("Beginning img downloads for $urlList at $imageDir");
  // begin downloads asynchronously.
  for (var url in urlList) {
    ref
        .read(urlToFilePathLookup.notifier)
        .state[url] = downloadImage(url: url, imageDir: imageDir.path);
  }
  print("Done");
  return bookList;
}
