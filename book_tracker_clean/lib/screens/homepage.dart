import 'dart:convert';

import 'package:book_tracker/fetch_data.dart';
import 'package:book_tracker/models/book_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SizedBox.expand(
        child: Align(
          alignment: Alignment.center,
          child: ElevatedButton(onPressed: () => myFunc(ref), child: Text("Placeholder")),
        ),
      )
    );
  }
}

void myFunc(WidgetRef ref) async {
  print("Beginning function");
  await fetchBooks(query: "title: harry potter", page: "1", ref: ref);
  // list of book json objects (List<Map<String, String>>
  final List<dynamic> fileJson = jsonDecode(await readChunk(chunk: 2, ref: ref));
  final chunk1 = fileJson
      .map((entry) => Map<String, String>.from(entry as Map));
  for (final entry in chunk1) {
    final object = BookData.fromJson(entry);
    print("${object.title} image: ${object.coverImageUrl}");
  }
  }
