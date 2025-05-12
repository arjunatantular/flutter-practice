
class TaskData { // holder for Task() parameters. So it can be easily inflated into a widget.
  final String name;
  final String startTime;
  final String endTime;
  final String priority;
  const TaskData({
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.priority
  });

  String timeRange() => "$startTime to $endTime";
}