import 'package:flutter/material.dart';
import '../models/task_data.dart';
import '../models/time_range.dart';
import '../widgets/time_select_section.dart';
import '../widgets/priority_select_screen.dart';
import '../utils/utils.dart';

class AddTaskScreen extends StatefulWidget {
  final TaskData? prefilledData; // prefilled TaskData, task index
  const AddTaskScreen({super.key, this.prefilledData});

  @override
  State<StatefulWidget> createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _timeFieldKey = GlobalKey<FormFieldState<TimeRange?>>();
  final _priorityFieldKey = GlobalKey<FormFieldState<String?>>();
  late final TextEditingController _taskNameController; // so we can grab values when needed
  late final TaskData? prefilledData;

  @override
  void initState() {
    super.initState();
    prefilledData = widget.prefilledData;
    _taskNameController = TextEditingController(text: prefilledData?.name ?? "");
  }


  // for each input: if prefilled is not null, prefill yourself with an initial value
  @override
  Widget build(BuildContext context) {
    // after the user selects a time, you should display what they selected to show it was confirmed.
    return Scaffold(
        body: Form(
            key: _formKey,
            child: SizedBox.expand(
              child: Column(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 40),
                      Align(alignment:  Alignment.center, child: Text("Add Task"),),
                      TextFormField( // Task name input
                        controller: _taskNameController,
                        validator: (value) {
                          if (value == null || value == "") return "Please enter a value.";
                          if (value.characters.length > 100) return "Please keep names under 100 chars.";
                          // No errors. properly validated:
                          return null;
                        },
                        decoration: InputDecoration(
                            hintText: "Task Name"
                        ),
                      ),
                      SizedBox(height: 30),
                      // Select time section
                      TimeSelectSection(
                          fieldKey: _timeFieldKey,
                          prefilled: prefilledData == null ? null : (prefilledData!.startTime, prefilledData!.endTime)
                      ),
                      SizedBox(height: 30),
                      // priority select section
                      PrioritySelectSection(
                          fieldKey: _priorityFieldKey,
                          prefilled: prefilledData?.priority
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()), // take up all remaining space
                  // Cancel and submit buttons in-line at bottom corners
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(onPressed: () {
                        Navigator.pop(
                            context,
                            [null, null, null, null]
                        );
                      }, child: Text("Cancel")),
                      ElevatedButton(onPressed: () {
                        // Validate form, then if valid send data.
                        if (_formKey.currentState!.validate()) {
                          // send data if it passes validation
                          final timeRange = _timeFieldKey.currentState!.value;
                          // pass raw list first to be turned into TaskDats by receiver
                          Navigator.pop(context, [
                            _taskNameController.text, // name
                            timeRange!.start!.to12HourFormat(), // startTime
                            timeRange.end!.to12HourFormat(), // endTime
                            _priorityFieldKey.currentState!.value // priority
                          ]
                          );
                        }
                      },
                          child: Text("Submit")
                      )
                    ],
                  ),
                ],
              ),
            )
        )
    );
  }

  @override
  void dispose() {
    super.dispose();
    _taskNameController.dispose();
  }

}
