import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/initializer_screen.dart'; // keep
import 'widgets/display_list.dart';

void main() {
  runApp(InitializerScreen());
}

class MyApp extends StatelessWidget {
  final ThemeMode mode; // Light or Dark theme
  const MyApp({super.key, required this.mode});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
            brightness: Brightness.dark,
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Colors.blueGrey,
            onSecondary: Colors.white60,
            error: Colors.blue,
            onError: Colors.indigo,
            surface: Colors.white30,
            onSurface: Colors.white60
        )
      ),
      themeMode: mode,
      home: MyHomePage(displayList: GlobalKey<DisplayListState>()),
    );
  }
}