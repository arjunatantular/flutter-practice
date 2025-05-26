import 'package:book_tracker/fetch_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/book_data.dart';

// BookCard with FavoriteButton in the top right
class BookCell extends StatelessWidget {
  // Should pass in a watch on the lookup table for your URL, in case the image changes.
  final BookData data;
  BookCell({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext builder, BoxConstraints constraints) {
      return Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: _BookCard(data: data),
          ),
          Align(
            alignment: Alignment(0.94, -0.94),
            child: _FavoriteButton(data: data),
          )
        ],
      );
    });
  }

}

// Image and text description underneath
class _BookCard extends StatelessWidget {
  late final String? title;
  late final String? authorName;
  late final String? publishDate;
  late final String? coverImageUrl;
  _BookCard({
    super.key,
    required BookData data
  })
      :
        title = data.title, 
        authorName = data.authorName, 
        publishDate = data.publishDate, 
        coverImageUrl = data.coverImageUrl;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.028;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1)
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
            children: [
              Flexible(
                  flex: 8,
                  fit: FlexFit.tight,
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(width: 1.0)
                          )
                      ),
                      child: _BookCardImage(coverImageUrl: coverImageUrl)
                  )
              ),
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          (title ?? "(Unknown title)") + (publishDate == null || publishDate == "" ? "" : " ($publishDate)"),
                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold)
                      ),
                      Text(
                        "by ${authorName ?? '(Unknown author)'}",
                        style: TextStyle(fontSize: fontSize, fontStyle: FontStyle.italic),
                      )
                    ],
                  )
              )
            ]
        )
      )
    );
  }
}

class _BookCardImage extends ConsumerWidget {
  final String? coverImageUrl;
  const _BookCardImage({
    super.key,
    required this.coverImageUrl,
  });

  // TODO: Perhaps have them pass this into an image variable and inflate an Image() at the end with all the config
  // TODO: Image needs to inflate to what its height and width should be
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no coverImage, display the no image file. If there is one, load it per usual.
    return LayoutBuilder(builder: (context, constraints) {
      return coverImageUrl == null
          ? const Image(image: AssetImage("assets/images/no_image.png"),)
          : Consumer(builder: (context, ref, _) {
        return FutureBuilder<String?>(
            future: ref.watch(urlToFilePathLookup)[coverImageUrl!],
            builder: (context, snapshot) {
              final ImageProvider<Object> rawImage;
              if (snapshot.connectionState == ConnectionState.waiting) {
                rawImage = AssetImage("assets/images/loading.jpg");
              } else if (snapshot.hasError) {
                print("Error: ");
                rawImage = AssetImage("assets/images/no_image.png");
              } else if (snapshot.hasData) { // Retrieved a value
                final filepath = snapshot.data;
                // No image was able to be retrieved / written:
                if (filepath == null) {
                  rawImage = AssetImage("assets/images/no_image.png");
                } else {
                  rawImage = FileImage(File(filepath));
                }
              } else {
                print("Error retrieving Image");
                rawImage = AssetImage("assets/images/no_image.png");
              }
              return Image(
                  image: rawImage,
                  width: constraints.maxHeight*0.67,
                  height: constraints.maxHeight,
                  fit: BoxFit.fill // should be minimal stretching w/ the standard 2:3 book cover ratio used
              );
            }
        );
      });
    });
  }
}

class _FavoriteButton extends StatefulWidget {
  final BookData data;
  const _FavoriteButton({super.key, required this.data});
  @override createState() => FavoriteButtonState();
}

class FavoriteButtonState extends State<_FavoriteButton> {
  late final BookData data;
  bool isPressed = false; // when true fill in button
  @override
  void initState() {
    super.initState();
    data = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(
      Icons.favorite,
      color: isPressed ? Colors.redAccent : Colors.white38,
      size: 47,
    ));
  }

  void onPressed() {
    setState(() {
      isPressed = !isPressed;
    });
    //print("Pressed");
    storeFavoriteBook();
  }

  void storeFavoriteBook() {
    // TODO: Write data to local DB to store as favorite books
  }
}

