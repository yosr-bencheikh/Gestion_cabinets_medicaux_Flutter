import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'constants.dart';

class History extends StatefulWidget {
  const History({Key? key}) : super(key: key);

  @override
  State<History> createState() => _AppointmentState();
}

class _AppointmentState extends State<History> {
  List<Map<String, dynamic>> appointments = [];

  @override
  void initState() {
    super.initState();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    List<Map<String, dynamic>>? fetchedAppointments = await fetchAllAppointments();
    if (fetchedAppointments != null) {
      setState(() {
        appointments = fetchedAppointments.where((appointment) => appointment['status'] == 'complete').toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Completed appointments',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Add some space
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  bool isLastElement = index == appointments.length - 1;
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: prColor,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: EdgeInsets.only(bottom: isLastElement ? 0 : 20),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(80),
                                child:
                                Image.network(appointment['avatar_url'],
                                  width: 80,
                                  height: 80,),

                              ),
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Doctor ${appointment['username']}',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    appointment['specialty'],
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${ DateFormat('dd-MM-yyyy').format(DateTime.parse(appointment['selected_date']))} at ${ appointment['selected_time']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> fetchAllAppointments() async {
    final userId = client.auth.currentUser!.id;
    try {
      final appointmentsResponse = await client.from('appointments').select().eq('user_id', userId);
      final doctorsResponse = await client.from('doctors').select();

      List<Map<String, dynamic>> combinedData = [];
      for (var appointment in appointmentsResponse) {
        var doctorInfo = doctorsResponse.firstWhere(
              (doctor) => doctor['id'] == appointment['doctor_id'],
          orElse: () => {},
        );

        Map<String, dynamic> combinedEntry = {
          'avatar_url': doctorInfo['avatar_url'] ?? 'No avatar url',
          'username': doctorInfo['username'] ?? 'No username',
          'specialty': doctorInfo['specialty'] ?? 'no specialty',
          'selected_time': appointment['selected_time'] ?? 'no time selected',
          'status': appointment['status']??'Awaiting' ,
          'selected_date':appointment['selected_date']??'no date selected',
        };

        combinedData.add(combinedEntry);
      }

      return combinedData;
    } catch (error) {
      print('Error fetching appointments: $error');
      return null;
    }
  }
}
