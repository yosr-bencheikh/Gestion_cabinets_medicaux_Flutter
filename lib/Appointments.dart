import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'DoctorHome.dart';
import 'constants.dart';

class Appointment extends StatefulWidget {
  const Appointment({Key? key}) : super(key: key);

  @override
  State<Appointment> createState() => _AppointmentState();
}

enum FilterStatus { Awaiting, upcoming, cancelled }

class _AppointmentState extends State<Appointment> {
  FilterStatus status = FilterStatus.Awaiting;
  Alignment _alignment = Alignment.centerLeft;
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
        appointments = fetchedAppointments;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredAppointments = appointments.where((appointment) {
      return appointment['status'] == status.toString().split('.').last;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Appointment Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10), // Add some space
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (filterStatus == FilterStatus.Awaiting) {
                                  status = FilterStatus.Awaiting;
                                  _alignment = Alignment.centerLeft;
                                } else if (filterStatus == FilterStatus.upcoming) {
                                  status = FilterStatus.upcoming;
                                  _alignment = Alignment.center;
                                } else if (filterStatus == FilterStatus.cancelled) {
                                  status = FilterStatus.cancelled;
                                  _alignment = Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.toString().split('.').last),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: Duration(milliseconds: 200),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: prColor, // Change to your preferred color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.toString().split('.').last,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10), // Add some space
            Expanded(
              child: ListView.builder(
                itemCount: filteredAppointments.length,
                itemBuilder: (context, index) {
                  var appointment = filteredAppointments[index];
                  bool isLastElement = index == filteredAppointments.length - 1;
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
                                child: Image.network(
                                  appointment['avatar_url'],
                                  width: 80,
                                  height: 80,
                                ),
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
                                    '${DateFormat('dd-MM-yyyy').format(DateTime.parse(appointment['selected_date']))} at ${appointment['selected_time']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  smallBox,
                                  if (appointment['status'] == 'Awaiting') // Show button only when status is 'Awaiting'
                                    ElevatedButton(
                                      onPressed: () {
                                        updateAppointmentStatus(appointment['id'],'cancelled');// Call the onAccept callback when Accept button is pressed
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.red,
                                        onPrimary: Colors.white,
                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: Text('Cancel'),
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
          'id': appointment['id'], // Include the 'id' field
          'avatar_url': doctorInfo['avatar_url'] ?? 'No avatar url',
          'username': doctorInfo['username'] ?? 'No username',
          'specialty': doctorInfo['specialty'] ?? 'no specialty',
          'selected_time': appointment['selected_time'] ?? 'no time selected',
          'status': appointment['status'] ?? 'Awaiting',
          'selected_date': appointment['selected_date'] ?? 'no date selected',
        };

        combinedData.add(combinedEntry);
      }

      return combinedData;
    } catch (error) {
      print('Error fetching appointments: $error');
      return null;
    }
  }}
