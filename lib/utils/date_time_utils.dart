import 'package:flutter/material.dart';

class DateTimeUtils {
  static TimeOfDay? parseTimeOfDay(String timeString) {
    if (timeString.isEmpty) return null;
    
    try {
      final utcTime = DateTime.parse("1970-01-01T$timeString");
      return TimeOfDay.fromDateTime(utcTime.toLocal());
    } catch (e) {
      return null;
    }
  }

  static String timeOfDayToString(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day, time.hour, time.minute)
        .toIso8601String()
        .split('T')
        .last;
  }

  static String dateToString(DateTime date) {
    return date.toIso8601String().split('T').first;
  }
}