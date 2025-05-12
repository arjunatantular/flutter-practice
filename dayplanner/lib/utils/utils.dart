import 'package:flutter/material.dart';

extension TimeOfDayFormatting on TimeOfDay {
  String to12HourFormat() { // from
    final h = hour > 12 ?  hour - 12 : hour; // trim down if > 12
    final m = minute < 10 ? "0$minute" : minute;
    final dayPeriod = period == DayPeriod.am ? "AM" : "PM";
    return "$h:$m $dayPeriod";
  }
}

extension StringFormatting on String {
  TimeOfDay toTimeOfDay() {
    // ["H:M", "dayPeriod"] (H = Hour, M = minute, same format as above function)
    final [hm, dayPeriod] = split(" ");
    final [h, m] = hm.split(":");
    return TimeOfDay(
        hour: int.parse(h) + (dayPeriod == "PM" ? 12 : 0),
        minute: int.parse(m)
    );
  }
}