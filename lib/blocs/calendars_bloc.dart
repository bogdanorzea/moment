import 'package:device_calendar/device_calendar.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarsBloc extends Cubit<CalendarsState> {
  final _deviceCalendarPlugin = DeviceCalendarPlugin();

  CalendarsBloc() : super(const CalendarsState());

  Future<void> retrieveCalendars() async {
    try {
      var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
      if (permissionsGranted.isSuccess && (permissionsGranted.data == null || permissionsGranted.data == false)) {
        permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
        if (!permissionsGranted.isSuccess || permissionsGranted.data == null || permissionsGranted.data == false) {
          return;
        }
      }

      final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();

      emit(CalendarsState(calendars: calendarsResult.data ?? <Calendar>[]));
    } on PlatformException catch (e) {
      emit(CalendarsState(failure: Failure(message: e.toString())));
    }
  }

  Future<List<Event>> _retrieveCalendarEventsForToday(String calendarId) async {
    final now = DateTime.now();

    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 1)).subtract(const Duration(minutes: 1));

    final calendarEventsResult = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startDate, endDate: endDate),
    );

    return calendarEventsResult.data ?? <Event>[];
  }

  Future<void> selectCalendar(String calendarId) async {
    final _selectedCalendars = {...state.selectedCalendarIds};
    if (state.selectedCalendarIds.contains(calendarId)) {
      _selectedCalendars.remove(calendarId);
    } else {
      _selectedCalendars.add(calendarId);
    }

    final events = <Event>[];
    for (final element in _selectedCalendars) {
      events.addAll(await _retrieveCalendarEventsForToday(element));
    }

    emit(
      state.copyWith(
        events: events,
        selectedCalendarIds: _selectedCalendars,
      ),
    );
  }
}

class CalendarsState extends Equatable {
  final bool isLoading;
  final List<Calendar> calendars;
  final Set<String> selectedCalendarIds;
  final List<Event> events;
  final Failure? failure;

  const CalendarsState({
    this.isLoading = false,
    this.calendars = const <Calendar>[],
    this.selectedCalendarIds = const <String>{},
    this.events = const <Event>[],
    this.failure,
  });

  @override
  List<Object?> get props => [isLoading, calendars, selectedCalendarIds, events, failure];

  CalendarsState copyWith({
    bool? isLoading,
    List<Calendar>? calendars,
    Set<String>? selectedCalendarIds,
    List<Event>? events,
    Failure? failure,
  }) {
    return CalendarsState(
      isLoading: isLoading ?? this.isLoading,
      calendars: calendars ?? this.calendars,
      selectedCalendarIds: selectedCalendarIds ?? this.selectedCalendarIds,
      events: events ?? this.events,
      failure: failure ?? this.failure,
    );
  }

  List<Calendar> get selectedCalendars => calendars.where((c) => selectedCalendarIds.contains(c.id)).toList();
}

class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object?> get props => [message];
}

extension CalendarsExtension on List<Calendar> {
  Map<String, List<Calendar>> get groupedByAccountName {
    final groupedCalendars = <String, List<Calendar>>{};

    for (final calendar in this) {
      final accountName = calendar.accountName ?? 'Unknown';

      if (groupedCalendars[accountName] == null) {
        groupedCalendars[accountName] = [calendar];
      } else {
        groupedCalendars[accountName]!.add(calendar);
      }
    }

    return groupedCalendars;
  }
}
