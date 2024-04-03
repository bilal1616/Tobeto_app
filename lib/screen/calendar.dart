// calendar.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tobeto_app/bloc/calendar_bloc/calendar_event_bloc.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late CalendarEventBloc _calendarEventBloc;

  @override
  void initState() {
    super.initState();
    _calendarEventBloc = CalendarEventBloc();
    _calendarEventBloc.initCalendar();
  }

  @override
  void dispose() {
    _calendarEventBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<CalendarState>(
        stream: _calendarEventBloc.stateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: TableCalendar(
                  focusedDay: state.focusedDay,
                  firstDay: DateTime(1990),
                  lastDay: DateTime(2050),
                  calendarFormat: state.calendarFormat,
                  selectedDayPredicate: (day) =>
                      state.events.any((event) => isSameDay(day, event.date)),
                  onDaySelected: _calendarEventBloc.onDaySelected,
                  onFormatChanged: _calendarEventBloc.onFormatChanged,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    todayBuilder: (context, date, events) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildEvents(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEvents(CalendarState state) {
    if (state.selectedDay == null) {
      state.events.sort((a, b) => a.date!.compareTo(b.date!));
      return ListView.builder(
        itemCount: state.events.length,
        itemBuilder: (context, index) {
          final event = state.events[index];
          final formattedDate =
              DateFormat('dd/MM/yyyy HH:mm').format(event.date!);

          return ListTile(
            title: Text(
              'Eğitim: ${event.education ?? ''}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eğitmen: ${event.instructor ?? ''}',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tarih: $formattedDate',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        },
      );
    } else {
      final selectedEvents = state.events
          .where((event) => isSameDay(state.selectedDay, event.date))
          .toList();

      selectedEvents.sort((a, b) => a.date!.compareTo(b.date!));

      return ListView.builder(
        itemCount: selectedEvents.length,
        itemBuilder: (context, index) {
          final event = selectedEvents[index];
          final formattedDate =
              DateFormat('dd/MM/yyyy HH:mm').format(event.date!);

          return ListTile(
            title: Text('Eğitim: ${event.education ?? ''}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eğitmen: ${event.instructor ?? ''}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tarih: $formattedDate',
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
