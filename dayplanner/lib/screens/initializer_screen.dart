import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme_wrapper.dart';

// Fetch SharedPref (data), pass to ThemeWrapper
class InitializerScreen extends StatelessWidget {
  const InitializerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder: (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: LoadingScreen());
        } else if (snapshot.hasError) {
          return MaterialApp(home: Text("Error (${snapshot.error}"));
        } else if (snapshot.hasData) {
          // Preference handler established
          return MaterialApp(home: ThemeWrapper(pref: snapshot.data!));
        } else {
          return MaterialApp(home: Text("Unable to locate data."));
        }
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            Text("Loading..."),
            CircularProgressIndicator()
          ],
        ),
      ),
    );
  }
}