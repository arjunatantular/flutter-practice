import 'package:flutter/material.dart';

class Task extends StatefulWidget {
  // Task name, time description, and priority
  // Ex. "Eat breakfast", "10:00am-10:30am" (yes I expect this to be stitched together by the time
  // you pass it in, and then "low". Priority = low/medium/high
  final String name;
  final String timeRange;
  final String priority;
  const Task({super.key, required this.name, required this.timeRange, required this.priority});

  @override
  State<StatefulWidget> createState() => TaskState();

}

class TaskState extends State<Task> {
  late final String name;
  late final String timeRange;
  late final Color priorityColor;

  static Color getColor(String priority) { // from priority
    switch(priority) {
      case "low":
        return Colors.grey;
      case "medium":
        return Colors.yellow;
      case "high":
        return Colors.red;
      default:
        throw Error();
    }
  }

  @override
  void initState() {
    super.initState();
    priorityColor = getColor(widget.priority);
    name = widget.name;
    timeRange = widget.timeRange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox( // left side (text column)
              height: 70,
              width: 307, // leave ~25 for the priority rectangle on the right
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        width: 3
                    )),
                child: SizedBox.expand(child: Column(// Top and bottom text
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name),
                      Text(timeRange)
                    ]
                )),
              ),
            ),
            SizedBox( // right side (priority column)
              height: 70,
              width: 18,
              child: Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(width: 3),
                        right: BorderSide(width: 3),
                        bottom: BorderSide(width: 3),
                        left: BorderSide.none
                    ),
                    color: priorityColor
                ),
              ),
            )
          ],
        )
    );
  }
}