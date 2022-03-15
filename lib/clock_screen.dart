import 'dart:ui';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moment/blocs/calendars_bloc.dart';
import 'package:moment/calendars_screen.dart';

class ClockScreen extends StatelessWidget {
  const ClockScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CalendarsScreen()));
                },
                icon: const Icon(Icons.calendar_today_rounded),
              ),
            ),
            Align(
              alignment: const Alignment(0, 1 / 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _CalendarEvents(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) {
        return Text(
          DateFormat('hh:mm:ss').format(DateTime.now()),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 72,
            fontWeight: FontWeight.bold,
            fontFeatures: <FontFeature>[
              FontFeature.tabularFigures(),
            ],
          ),
        );
      },
    );
  }
}

class _CalendarEvents extends StatefulWidget {
  const _CalendarEvents({Key? key}) : super(key: key);

  @override
  State<_CalendarEvents> createState() => _CalendarEventsState();
}

class _CalendarEventsState extends State<_CalendarEvents> {
  @override
  void initState() {
    super.initState();

    context.read<CalendarsBloc>().retrieveCalendars();
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<CalendarsBloc>().state.events;
    final now = DateTime.now();
    final pastEvents = events.where((element) => element.start!.toLocal().isBefore(now));
    final futureEvents = events.where((element) => element.start!.toLocal().isAfter(now));

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...pastEvents.map((Event e) => EventWidget(event: e)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: _Clock(),
        ),
        ...futureEvents.map((Event e) => EventWidget(event: e)),
      ],
    );
  }
}

class EventWidget extends StatelessWidget {
  final Event event;

  const EventWidget({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var time = '';
    if (event.allDay != true) {
      final startTime = event.start;
      if (startTime != null) {
        const format = 'h:mma';

        time = '${DateFormat(format).format(event.start!).toLowerCase()}: ';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$time${event.title}',
        style: TextStyle(
          color: event.start!.isBefore(DateTime.now()) ? Theme.of(context).disabledColor : null,
          fontFamily: 'Inter',
          fontSize: 18,
          fontFeatures: const <FontFeature>[
            FontFeature.tabularFigures(),
          ],
        ),
      ),
    );
  }
}
