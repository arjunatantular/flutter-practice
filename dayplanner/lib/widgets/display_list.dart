import 'package:flutter/material.dart';
import 'task.dart';
import '../models/task_data.dart';
import '../screens/add_task_screen.dart';

class DisplayList extends StatefulWidget {
  // Take in a list of Tasks, and generate these into UI via a scrollable column.
  final List<TaskData> taskDataList;
  const DisplayList({super.key, required this.taskDataList});
  @override
  State<StatefulWidget> createState() => DisplayListState();
}

class DisplayListState extends State<DisplayList> {
  // store and modify data here, will be inflated upon build()
  late List<TaskData> taskDataList;

  void addTask({ // for external use
    required String taskName,
    required String startTime,
    required String endTime,
    required String priority
  }) {
    setState(() {
      taskDataList.add(
          TaskData(
              name: taskName,
              startTime: startTime,
              endTime: endTime,
              priority: priority));
    });
  }

  void clearTasks() {
    setState(() {
      taskDataList = <TaskData>[];
    });
  }

  List<Widget> buildTaskList(BuildContext context) {
    // workaround for .mapIndexed()
    return taskDataList.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return GestureDetector(
        onDoubleTap: () => editTask(context: context, index: index),
        child: Task(
          // For diffing, if two tasks have the same index, same display info,
          // then you may reuse the old one. otherwise, rebuild.
          key: ValueKey("$index${item.name}${item.startTime}${item.endTime}${item.priority}"),
          name: item.name,
          timeRange: "${item.startTime} to ${item.endTime}",
          priority: item.priority,
        ),
      );
    } ).toList();
  }

  Future<void> editTask({required BuildContext context, required int index}) async {
    final taskData = taskDataList[index]; // task to be edited
    final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddTaskScreen(
          prefilledData: taskData,
        ))
    );
    // If they hit cancel ([null, null, null, null]) don't do anything. Otherwise update the task.
    if (!result.any((e) => e == null)) {
      final newTask = TaskData(
          name: result[0],
          startTime: result[1],
          endTime: result[2],
          priority: result[3]
      );
      // replace the old task with the new, updated one
      setState(() {
        taskDataList[index] = newTask;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    taskDataList = List.from(widget.taskDataList);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
            child: Column(
                children: buildTaskList(context)
            )
        )
    );
  }
}