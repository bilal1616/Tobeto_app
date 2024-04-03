// calendar_event_bloc.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tobeto_app/widget/calendar_widget/calendar_model.dart';

class CalendarState {
  final DateTime focusedDay;
  final CalendarFormat calendarFormat;
  final DateTime? selectedDay;
  final List<CalendarEvent> events;

  CalendarState({
    required this.focusedDay,
    required this.calendarFormat,
    required this.selectedDay,
    required this.events,
  });
}

class CalendarEventBloc {
  late List<CalendarEvent> _events;
  late CalendarState _calendarState;
  late StreamController<CalendarState> _stateController;

  CalendarEventBloc() {
    _events = [];
    _calendarState = CalendarState(
      focusedDay: DateTime.now(),
      calendarFormat: CalendarFormat.month,
      selectedDay: null,
      events: _events,
    );
    _stateController = StreamController<CalendarState>.broadcast();
  }

  Stream<CalendarState> get stateStream => _stateController.stream;

  void initCalendar() {
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userId = user.uid;
      final events = <CalendarEvent>[];
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final calendarCollection = userDoc.reference.collection('calendar');
        final snapshot = await calendarCollection.get();
        events.addAll(snapshot.docs
            .map((doc) => CalendarEvent.fromFirestore(doc))
            .toList());
      }

      _events = events;
      _updateState();
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _calendarState = _calendarState.copyWith(
      focusedDay: focusedDay,
      selectedDay: selectedDay,
    );
    _updateState();
  }

  void onFormatChanged(CalendarFormat format) {
    _calendarState = _calendarState.copyWith(calendarFormat: format);
    _updateState();
  }

  void _updateState() {
    _calendarState = _calendarState.copyWith(events: _events);
    _stateController.sink.add(_calendarState);
  }

  void dispose() {
    _stateController.close();
  }
}

extension CalendarStateExtension on CalendarState {
  CalendarState copyWith({
    DateTime? focusedDay,
    CalendarFormat? calendarFormat,
    DateTime? selectedDay,
    List<CalendarEvent>? events,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      calendarFormat: calendarFormat ?? this.calendarFormat,
      selectedDay: selectedDay ?? this.selectedDay,
      events: events ?? this.events,
    );
  }
}
