import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'constants.dart';

class Notifications extends StatelessWidget {
  const Notifications({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 22,),
          FutureBuilder<List<Appointment>>(
            future: getAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return Container(
                  height: 680,
                  child: SfCalendar(
                    view: CalendarView.week,
                    firstDayOfWeek: 6,
                    todayHighlightColor: prColor,
                    headerStyle: CalendarHeaderStyle(
                      textAlign: TextAlign.center,backgroundColor: prColor,
                    ),
                    dataSource: MeetingDataSource(snapshot.data ?? []),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}



Future<List<Appointment>> getAppointments() async {
  List<Appointment> meetings = <Appointment>[];
  final userId = client.auth.currentUser!.id;

  try {
    final response = await client.from('appointments').select().eq('doctor_id', userId).eq('status', 'upcoming');

    if (response.isEmpty) {
      print('Error fetching appointments');
      return meetings;
    }

    final List<dynamic> data = response;

    for (var appointmentData in data) {
      final DateTime startTime = DateFormat('yyyy-MM-dd hh:mm a').parse('${appointmentData['selected_date']} ${appointmentData['selected_time']}');
      final DateTime endTime = startTime.add(Duration(hours: 1));

      meetings.add(Appointment(
        subject: 'appointment',
        startTime: startTime,
        color: prColor,
        endTime: endTime,
        notes: '',
      ));
    }
  } catch (error) {
    print('Error: $error');
  }

  return meetings;
}


class MeetingDataSource extends CalendarDataSource{
  MeetingDataSource(List<Appointment>source){
    appointments=source;
  }
}
