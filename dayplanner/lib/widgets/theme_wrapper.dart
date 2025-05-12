import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

// ThemeWrapper section (to track Theme State and make it accessible to widgets below)

class ThemeWrapper extends StatefulWidget {
  final SharedPreferences pref; // handle for SharedPreferences
  const ThemeWrapper({super.key, required this.pref});

  @override
  State<StatefulWidget> createState() => ThemeWrapperState();
}

class ThemeWrapperState extends State<ThemeWrapper> {
  // light by default (if no previous val it will be set to light)
  late final SharedPreferences pref;
  late ThemeMode _mode;

  @override
  void initState() {
    super.initState();
    // initialize pref handle
    pref = widget.pref;
    // initialize _mode and isDarkTheme if needed
    if (!pref.containsKey("isDarkTheme")) { // there is no preference yet
      // make it by default light:
      pref.setBool("isDarkTheme", false);

    }
    _mode = pref.getBool("isDarkTheme")! ? ThemeMode.dark : ThemeMode.light;
  }

  void _toggle() {
    setState(() {
      if (_mode == ThemeMode.light) {
        _mode = ThemeMode.dark;
        pref.setBool("isDarkTheme", true);
      } else {
        _mode = ThemeMode.light;
        pref.setBool("isDarkTheme", false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeController(
        mode: _mode,
        toggle: _toggle,
        child: MyApp(mode: _mode)
    );
  }
}

class ThemeController extends InheritedWidget {
  final ThemeMode mode;
  // The StatefulWidget method that will be broadcast to toggle the mode state
  final void Function() toggle;
  const ThemeController({super.key,
    required this.mode,
    required this.toggle,
    required super.child // Will be MyApp()
  });

  @override
  bool updateShouldNotify(covariant ThemeController oldWidget) {
    // the only thing that would change would be mode. If it changes notify subscribers
    return oldWidget.mode != mode;
  }

  static ThemeController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeController>();
  }

  static ThemeController of(BuildContext context) {
    final ThemeController? result = maybeOf(context);
    assert(result != null, "No ThemeController found within context");
    return result!;
  }

}