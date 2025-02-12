import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:timezone/timezone.dart' as tz;

part 'reminder_event.dart';
part 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc() : super(ReminderInitial());

  int? selectedRepeatDayIndex;
  late DateTime reminderTime;
  int? dayTime;

  @override
  Stream<ReminderState> mapEventToState(
    ReminderEvent event,
  ) async* {
    if (event is RepeatDaySelectedEvent) {
      selectedRepeatDayIndex = event.index;
      dayTime = event.dayTime;
      yield RepeatDaySelectedState(index: selectedRepeatDayIndex);
    } else if (event is ReminderNotificationTimeEvent) {
      reminderTime = event.dateTime;
      yield ReminderNotificationState();
    } else if (event is OnSaveTappedEvent) {
      _scheduleAtParticularTimeAndDate(reminderTime, dayTime);
      yield OnSaveTappedState();
    }
  }

  Future _scheduleAtParticularTimeAndDate(
      DateTime dateTime, int? dayTime) async {
    final flutterNotificationsPlugin = FlutterLocalNotificationsPlugin();
    
    // ✅ Correction: Suppression du troisième paramètre positionnel et ajout de paramètres requis
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_other_channel_id', 
      'your_other_channel_name', 
      channelDescription: 'your other channel description', // ✅ Correction
      importance: Importance.max,
      priority: Priority.high,
    );

    // ✅ Correction: Remplacement de IOSNotificationDetails() par DarwinNotificationDetails()
    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterNotificationsPlugin.zonedSchedule(
      1,
      "Fitness",
      "Hey, it's time to start your exercises!",
      _scheduleWeekly(dateTime, days: _createNotificationDayOfTheWeek(dayTime)),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // ✅ Correction ajoutée
    );
  }

  tz.TZDateTime _scheduleDaily(DateTime dateTime) {
    final now = tz.TZDateTime.now(tz.local);
    var timezoneOffset = DateTime.now().timeZoneOffset;
    final scheduleDate = tz.TZDateTime.utc(now.year, now.month, now.day)
        .add(Duration(hours: dateTime.hour, minutes: dateTime.minute))
        .subtract(Duration(hours: timezoneOffset.inHours));

    return scheduleDate.isBefore(now)
        ? scheduleDate.add(Duration(days: 1))
        : scheduleDate;
  }

  tz.TZDateTime _scheduleWeekly(DateTime dateTime, {required List<int>? days}) {
    tz.TZDateTime scheduleDate = _scheduleDaily(dateTime);

    for (final int day in days ?? []) {
      scheduleDate = scheduleDate.add(Duration(days: day));
    }

    return scheduleDate;
  }

  List<int> _createNotificationDayOfTheWeek(int? dayTime) {
    switch (dayTime) {
      case 0:
        return [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday
        ];
      case 1:
        return [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday
        ];
      case 2:
        return [DateTime.saturday, DateTime.sunday];
      case 3:
        return [DateTime.monday];
      case 4:
        return [DateTime.tuesday];
      case 5:
        return [DateTime.wednesday];
      case 6:
        return [DateTime.thursday];
      case 7:
        return [DateTime.friday];
      case 8:
        return [DateTime.saturday];
      case 9:
        return [DateTime.sunday];
      default:
        return [];
    }
  }
}
