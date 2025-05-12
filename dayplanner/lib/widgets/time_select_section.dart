import 'package:flutter/material.dart';
import '../models/time_range.dart';
import '../utils/utils.dart';

class TimeSelectSection extends StatelessWidget {
  final GlobalKey<FormFieldState<TimeRange?>> fieldKey;
  final TimeOfDay? prefilledStart;
  final TimeOfDay? prefilledEnd;
  TimeSelectSection({
    super.key,
    required this.fieldKey,
    (String, String)? prefilled
  }):prefilledStart = prefilled?.$1.toTimeOfDay(),
        prefilledEnd = prefilled?.$2.toTimeOfDay();

  @override
  Widget build(BuildContext context) {
    return FormField<TimeRange>(
        key: fieldKey,
        initialValue: TimeRange(start: prefilledStart, end: prefilledEnd),
        validator: (value) {
          if (value?.start == null || value?.end == null) return "Please enter a start and end time.";
          if (value!.start!.isAfter(value.end!)) return "Please make sure your time range is valid.";
          return null;
        },
        builder: (FormFieldState<TimeRange> state) {
          final oldValue = state.value!;
          return Column(
            children: [
              Text("Time"),
              Row(children: [
                SizedBox(width: 40),
                Text("\tStart: ${oldValue.start == null ? '' : oldValue.start!.to12HourFormat()}"),
                ElevatedButton(
                    onPressed: () => pickTime(context: context, start: true, state: state),
                    child: Icon(Icons.lock_clock))
              ]),
              Row(children: [
                SizedBox(width: 40),
                Text("\tEnd: ${oldValue.end == null ? '' : oldValue.end!.to12HourFormat()}"),
                ElevatedButton(
                    onPressed: () => pickTime(context: context, start: false, state: state),
                    child: Icon(Icons.lock_clock))
              ]),
              if(state.hasError)
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("${state.errorText}"))
            ],
          );
        }
    );
  }


  // bool start = to edit start time or end time with this val? true = start
  Future<void> pickTime({
    required BuildContext context,
    required bool start,
    required FormFieldState<TimeRange> state
  }) async {
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    final oldValue = state.value!;
    // If setting start time, only set start time and vice versa.
    final newValue = oldValue.setTime(
        start: start ? pickedTime : null,
        end: start ? null : pickedTime
    );
    // set new val
    state.didChange(newValue);
  }
}