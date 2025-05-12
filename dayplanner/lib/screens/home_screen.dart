import 'package:flutter/material.dart';
import '../widgets/display_list.dart';
import '../widgets/theme_wrapper.dart';
import '../models/task_data.dart';
import 'add_task_screen.dart';

class MyHomePage extends StatelessWidget {
  final GlobalKey<DisplayListState> displayList;

  const MyHomePage({super.key, required this.displayList});


  void onPressed(BuildContext context) async { // when the add task button is pressed:
    final List<String?> result = await Navigator.push( // Push new screen, receive new taskData to added to list.
        context,
        MaterialPageRoute(builder: (context) => AddTaskScreen())
    );
    // Check to see if all of them are null, if so then the user cancelled so there is no taskData to add.
    if (result != [null, null, null, null]) {
      // Once taskData is received, add it to our list via our displayList key.
      displayList.currentState!.addTask(
          taskName: result[0]!,
          startTime: result[1]!,
          endTime: result[2]!,
          priority: result[3]!
      );
      // Now the UI should refresh along with our new info.
    }
  }

  @override
  Widget build(BuildContext context) {
    // Can fill with example values in code if you want to see how it renders.
    final test = <TaskData>[];
    return Scaffold(
        body: Stack(
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Today"),
                  SizedBox(
                    height: 600,
                    child: Flexible(child: DisplayList(key: displayList, taskDataList: test,)),
                  )
                ]
            ),
            Align( // add new task / swap to task add screen
              alignment: Alignment.bottomRight,
              child: ElevatedButton(onPressed: () => onPressed(context), child: Text("+")),
            ),
            Align( // clear current list
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(onPressed: () => displayList.currentState!.clearTasks(), child: Text("Clear")),
            ),
            Align(
                alignment: Alignment(0.95, -0.95),
                child: ThemeSwitchButton()
            ),
          ],
        )
    );
  }
}

class ThemeSwitchButton extends StatelessWidget {
  // Not stateful b/c Reads from ThemeController.of() for state, doesn't mutate internally.
  const ThemeSwitchButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end, // we want it to be top right
      children: [
        // Sun button
        ElevatedButton(
            onPressed: () => controller.toggle(),
            child: Icon(
                Icons.light_mode,
                color: controller.mode == ThemeMode.light ? Colors.yellow : Colors.black
            )
        ),
        // Moon button
        ElevatedButton(
            onPressed: () => controller.toggle(),
            child: Icon(
                Icons.dark_mode,
                color: controller.mode == ThemeMode.light ? Colors.grey : Colors.black
            )
        )
      ],
    );
  }
}
