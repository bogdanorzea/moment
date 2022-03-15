import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moment/blocs/calendars_bloc.dart';

class CalendarsScreen extends StatelessWidget {
  const CalendarsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final calendarBloc = context.watch<CalendarsBloc>();
    final selectedCalendars = calendarBloc.state.selectedCalendarIds;
    final calendars = calendarBloc.state.calendars.groupedByAccountName;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendars')),
      body: ListView(
        children: [
          ...calendars.values.map(
            (cs) => Column(
              children: [
                if (cs.isNotEmpty) ListTile(subtitle: Text(cs.first.accountName!.toUpperCase())),
                ...cs.map(
                  (Calendar c) => ListTile(
                    title: Text(c.name ?? ''),
                    trailing: selectedCalendars.contains(c.id) ? const Icon(Icons.check_rounded) : null,
                    onTap: () {
                      final calendarId = c.id;
                      if (calendarId == null) return;

                      calendarBloc.selectCalendar(calendarId);
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
