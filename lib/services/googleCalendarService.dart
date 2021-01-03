import 'dart:developer';

import 'package:docup/models/PatientEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/utils/dateTimeService.dart';
import 'package:googleapis/calendar/v3.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:url_launcher/url_launcher.dart';

class GoogleCalenderService {
  static Future<bool> addVisitEvent(
      VisitEntity visitEntity, PatientEntity patientEntity) async {
    String description = visitEntity.visitTypeAndMethodDescription +
        "\n" +
        "بیمار " +
        patientEntity.fullName;
    DateTime startDateTime =
        DateTimeService.getDateTimeFromStandardString(visitEntity.visitTime);
    DateTime endDateTime =
        startDateTime.add(Duration(minutes: visitEntity.visitDurationMinutes));
    bool result = await GoogleCalendarClient.addEvent(
        "ویزیت", startDateTime, endDateTime,
        description: description, id: visitEntity.id.toString());
    return result;
  }
}

class GoogleCalendarClient {
  static String googleCalendarApiClientId =
      "99371011607-bomm6f5bahnv9fsaqksslsjla19n84fm.apps.googleusercontent.com";

  static const _scopes = const [CalendarApi.CalendarScope];

  static Future<bool> addEvent(
      String title, DateTime startTime, DateTime endTime,
      {String description = "", String id}) async {
    var _clientID = new ClientId(googleCalendarApiClientId, "");
    AuthClient client = await clientViaUserConsent(_clientID, _scopes, prompt);
    var calendar = CalendarApi(client);
    calendar.calendarList.list().then((value) => print("VAL________$value"));

    String calendarId = "primary";
    Event event = Event(); // Create object of event

    event.summary = title;
    event.description = description;
    event.colorId = "2";

    EventDateTime start = new EventDateTime();
    start.dateTime = startTime;
    start.timeZone = "GMT+03:00";
    event.start = start;

    EventDateTime end = new EventDateTime();
    end.timeZone = "GMT+03:00";
    end.dateTime = endTime;
    event.end = end;
    try {
      Event value = await calendar.events.insert(event, calendarId);
      if (value.status == "confirmed") {
        return true;
      } else {
        log("Unable to add event in google calendar");
      }
    } catch (e) {
      log('Error creating event $e');
    }
    return false;
  }

  static void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
