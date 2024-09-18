import 'package:doctor_appointment/Custom_appbar.dart';
import 'package:doctor_appointment/successPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'constants.dart';

class BookingPage extends StatefulWidget {
  final String doctorId;
  const BookingPage({Key? key, required this.doctorId}) : super(key: key);
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  int? _currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: CustomAppBar(
          appTitle: 'Appointments',
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                ),
                Text(
                  'Select the time of the appointment',
                  style: TextStyle(color: prColor, fontWeight: FontWeight.bold),
                ),
                smallBox,
                // Add other widgets here if needed
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
              alignment: Alignment.center,
              child: Text(
                'Weekend is not available, please select another date',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
          )
              : SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                      _timeSelected = true;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentIndex == index
                            ? Colors.white
                            : Colors.black,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      color: _currentIndex == index ? prColor : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _currentIndex == index
                            ? Colors.white
                            : null,
                      ),
                    ),
                  ),
                );
              },
              childCount: 8,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.5,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: ElevatedButton(
                onPressed: () async {
                  if (_timeSelected && _dateSelected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SuccessPage(),
                      ),
                    );
                    await saveAppointment();
                  }
                },
                child: Text('Send the appointment request'),
                style: ElevatedButton.styleFrom(
                  primary: _timeSelected && _dateSelected ? prColor : Colors.grey,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime(2024, 12, 31),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: prColor,
          shape: BoxShape.circle,
        ),
      ),
      availableCalendarFormats: {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      },
    );
  }
  Future<void> saveAppointment() async {
    final user = client.auth.currentUser;

    if (user != null) {
      final response = await client
          .from('appointments')
          .upsert([
        {
          'user_id': user.id,
          'doctor_id': widget.doctorId, // Use widget.doctorId here
          'selected_date': _currentDay.toIso8601String(),
          'selected_time': _currentIndex != null
              ? '${_currentIndex! + 9}:00 ${_currentIndex! + 9 > 11 ? "PM" : "AM"}'
              : '',
          'status':'Awaiting',
        }
      ]);

      if (response.error != null) {
        print('Error saving appointment: ${response.error!.message}');
      } else {
        print('Appointment saved successfully!');
      }
    }
  }}

