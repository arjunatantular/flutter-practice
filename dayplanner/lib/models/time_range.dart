import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay? start;
  final TimeOfDay? end;
  const TimeRange({this.start, this.end});

  // Return a new instance with new vals. if new val is null, dont override the last one
  TimeRange setTime({TimeOfDay? start, TimeOfDay? end}) {
    return TimeRange(
        start: start ?? this.start,
        end: end ?? this.end
    );
  }
}

