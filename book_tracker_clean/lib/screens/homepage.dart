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
  final chunk1 = jsonDecode(await readChunk(chunk: 1, ref: ref));
  print(chunk1);
  }
