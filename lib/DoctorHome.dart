import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';


class DoctorHome extends StatefulWidget {
  const DoctorHome({Key? key}) : super(key: key);

  @override
  _DoctorHomeState createState() => _DoctorHomeState();
}

class _DoctorHomeState extends State<DoctorHome> with WidgetsBindingObserver {
  List<Map<String, dynamic>> appointments = [];
  bool isDoctor = false;  // Assume the user is not a doctor initially
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    // Add the WidgetsBindingObserver
    WidgetsBinding.instance?.addObserver(this);
    // Check the user's role (doctor or patient)
    checkUserRole();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false;
    // Remove the WidgetsBindingObserver
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  Future<void> checkUserRole() async {
    try {
      // Fetch user data to determine the role
      final roleResponse = await fetchUserData('role');
      // Check if the user is a doctor
      isDoctor = roleResponse == 'doctor';
      // Fetch appointments only if the user is a patient
      if (!isDoctor && _isMounted) {
        fetchAppointments();
      }
    } catch (error) {
      print('Error fetching user role: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !isDoctor && _isMounted) {
      // Fetch appointments only if the user is a patient and the widget is mounted
      fetchAppointments();
    }
  }

  Future<void> fetchAppointments() async {
    try {
      List<Map<String, dynamic>>? fetchedAppointments = await fetchAllAppointments();

      if (fetchedAppointments != null && _isMounted) {
        // Check if the appointment has passed by an hour and update the status
        checkAndUpdateAppointmentStatus(fetchedAppointments);

        setState(() {
          appointments = fetchedAppointments;
        });
      }
    } catch (error) {
      print('Error fetching appointments: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 16),
            UserInfoCard(),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your appointment requests',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            smallBox,
            Expanded(
              child: ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  var appointment = appointments[index];
                  bool isLastElement = index == appointments.length - 1;
                  return AppointmentCard(
                    appointment: appointment,
                    isLast: isLastElement,
                    onAccept: () {
                      acceptAppointment(appointment['id']);
                    },
                    onDecline: () {
                      declineAppointment(appointment['id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void acceptAppointment(int appointmentId) {
    updateAppointmentStatus(appointmentId, 'upcoming');
    fetchAppointments(); // Refresh appointments after update
  }

  void declineAppointment(int appointmentId) {
    updateAppointmentStatus(appointmentId, 'cancelled');
     // Refresh appointments after update
  }
}

class AppointmentCard extends StatelessWidget {
  final Map<String, dynamic> appointment;
  final bool isLast;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.isLast,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(appointment['id']), // Use appointment ID as the key
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: Colors.blue, // Change to your preferred color
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(
        bottom: isLast ? 0 : 20,
      ),
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
                      '${appointment['username']}',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Phone number: ${appointment['Phone_number']?.toString() ?? 'N/A'}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text('Appointment date :'),
                    Text(
                      '${DateFormat('dd-MM-yyyy').format(DateTime.parse(appointment['selected_date']))} at ${appointment['selected_time']}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Call the onAccept callback when Accept button is pressed
                            onAccept();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Accept'),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Call the onDecline callback when Decline button is pressed
                            // Show confirmation dialog before declining the appointment
                            showConfirmationDialog(context, appointment['id']);

                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            onPrimary: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text('Decline'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class UserInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextEditingController _searchController = TextEditingController();

    // Get screen size
    double screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<String?>(
      future: fetchUserData('avatar_url'),
      builder: (context, AsyncSnapshot<String?> imageUrlSnapshot) {
        if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (imageUrlSnapshot.hasError || imageUrlSnapshot.data == null) {
          // Handle the error condition when fetching image URL
          return Text('Error fetching image URL');
        } else {
          return FutureBuilder<String?>(
            future: fetchUserData('username'),
            builder: (context, AsyncSnapshot<String?> usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (usernameSnapshot.hasError || usernameSnapshot.data == null) {
                // Handle the error condition when fetching username
                return Text('Error fetching username');
              } else {
                return Container(
                  height: screenHeight * 0.2,
                  width: double.infinity,
                  child: Card(
                    color: prColor,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.waving_hand),
                          title: Text("Hello"),
                          subtitle: Text(
                            "Doctor ${usernameSnapshot.data!}",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          trailing: Container(
                            width: 60,
                            height: 60,
                            child: ClipOval(
                              child: Image.network(
                                imageUrlSnapshot.data!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Container(
                          height: 45,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              // Implement your search logic here
                              // You may want to filter the names based on the entered text
                              // and update the UI accordingly
                            },
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.search, color: Colors.black87),
                              labelText: 'How can we help you?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}

Future<String?> fetchUserData(String col) async {
  try {
    // Replace this with your actual implementation to fetch user data
    final user_name = await client
        .from('doctors')
        .select(col)
        .eq('id', client.auth.currentUser!.id)
        .single();

    return user_name[col] as String?;
  } catch (error) {
    return null;
  }
}

Future<List<Map<String, dynamic>>> fetchAllAppointments() async {
  final userId = client.auth.currentUser!.id;
  try {
    // Replace this with your actual implementation to fetch appointments
    final appointmentsResponse = await client
        .from('appointments')
        .select().eq('doctor_id', userId).eq('status', 'Awaiting');
    final patientsResponse = await client.from('profiles').select();

    List<Map<String, dynamic>> combinedData = [];
    print('Appointments Response: $appointmentsResponse');
    for (var appointment in appointmentsResponse) {
      print('Processing Appointment: $appointment');
      var patientInfo = patientsResponse.firstWhere(
            (patient) => patient['id'] == appointment['user_id'],
        orElse: () => {}, // Return null if patient not found
      );


      if (patientInfo != null) {
        Map<String, dynamic> combinedEntry = {
          'id':appointment['id'],
          'avatar_url': patientInfo['avatar_url'] ?? 'No avatar url',
          'username': patientInfo['username'] ?? 'No username',
          'Phone_number': patientInfo['Phone_number'] ?? 'No phone number',
          'selected_time': appointment['selected_time'] ?? 'No time selected',
          'status': appointment['status'] ?? 'Awaiting',
          'selected_date': appointment['selected_date'] ?? 'No date selected',
        };

        combinedData.add(combinedEntry);
      }
    }

    return combinedData;
  } catch (error) {
    print('Error fetching appointments: $error');
    return [];
  }
}

Future<void> updateAppointmentStatus(int? appointmentId, String newStatus) async {
  try {
    if (appointmentId != null) {
      // Replace this with your actual implementation to update appointment status
      await client.from('appointments').update({
        'status': newStatus,
      }).eq('id', appointmentId);
    } else {
      print('Error: Appointment ID is null');
    }
  } catch (error) {
    print('Error updating appointment status: $error');
  }
}

Future<void> showConfirmationDialog(BuildContext context, int appointmentId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Decline'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Are you sure you want to decline this appointment?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Yes'),
            onPressed: () {
              Navigator.of(context).pop();
              updateAppointmentStatus(appointmentId, 'cancel');

            },
          ),
        ],
      );
    },
  );
}

Future<void> checkAndUpdateAppointmentStatus(List<Map<String, dynamic>> appointments) async {
  for (var appointment in appointments) {
    // Parse selected date and time from the appointment
    DateTime selectedDateTime = DateFormat('yyyy-MM-dd hh:mm a').parse('${appointment['selected_date']} ${appointment['selected_time']}');
    print('Selected DateTime: $selectedDateTime');

    // Compare with the current time
    if (DateTime.now().isAfter(selectedDateTime)) {
      await updateAppointmentStatus(appointment['id'], 'complete');
      print('Status updated for appointment ID ${appointment['id']}');
    }
  }
}
