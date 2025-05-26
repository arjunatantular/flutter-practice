import 'package:book_tracker/parse_data.dart';
import 'package:book_tracker/widgets/BookCell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book_data.dart';

class Gallery extends ConsumerWidget {
  Gallery({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: FutureBuilder<List<BookData>>(
            future: parseChunk(1, ref),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                print("Loading");
                return Text("Loading");
              } else if (snapshot.hasError) {
                print("Error");
                return Text("Error");
              } else if (snapshot.hasData) {
                print("Got data: ${snapshot.data![3].title}");
                return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      return BookCell(data: snapshot.data![index]);
                    });
              } else {
                print("Strange error");
                return Text("Strange error");
              }
            }
        ),
      )
    );
  }
}