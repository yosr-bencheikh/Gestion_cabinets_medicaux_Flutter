import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Appointments' list"),
      ),

      body: Container(
        color: Colors.white, 
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 20.0),
          child: FutureBuilder<List<Map<String, dynamic>>?>(
            future: fetchAllAppointments(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>?> doctorsSnapshot) {
              if (doctorsSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (doctorsSnapshot.hasError || doctorsSnapshot.data == null) {
               
                return Text('Error fetching patients data');
              } else {

               
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: doctorsSnapshot.data!.length,
                  itemBuilder: (context, index) {
                  
                    bool isEvenIndex = index.isEven;

                 
                    if (isEvenIndex) {
                      int nextIndex = index + 1;
                      if (nextIndex < doctorsSnapshot.data!.length) {
                        final patientData1 = doctorsSnapshot.data![index];
                        final patientData2 = doctorsSnapshot.data![nextIndex];

                        return Row(
                          children: [
                            SizedBox(height: 20,),
                            Expanded(
                              child: PatientList(
                                patientImagePath: patientData1['avatar_url_patient'] ?? 'no image',
                                Name: 'Dr ${patientData1['doctor_name']}  and  ${patientData1['username']} ',
                                patientId: patientData1['id'].toString(), date_time: '${patientData1['selected_time']} at ${patientData1['selected_date']}', doctorImagePath: patientData1['avatar_url_doctor'] ,
                              ),
                            ),
                            Expanded(
                              child: PatientList(

                                Name: 'Dr ${patientData2['doctor_name']}  and  ${patientData2['username']} ',
                                patientId: patientData2['id'].toString(), patientImagePath: patientData2['avatar_url_patient'], date_time: '${patientData2['selected_time']} at ${patientData2['selected_date']}', doctorImagePath: patientData2['avatar_url_doctor'],
                              ),
                            ),
                          ],
                        );
                      }
                    }

                    // Return an empty container for odd index
                    return Container();
                  },
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class PatientList extends StatelessWidget {
  final String? patientImagePath;
  final String? doctorImagePath;
  final String Name;
  final String date_time;
  final String patientId; // Add patientId to uniquely identify each patient
  final VoidCallback? onDeletePressed;

  const PatientList({
    Key? key,
    required this.patientImagePath,
    required this.patientId,
    this.onDeletePressed, required this.doctorImagePath, required this.Name, required this.date_time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 15),
      child: Container(
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: prColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: Image.network(
                    doctorImagePath ?? 'default_image_path',
                    width: 70,
                    height: 70,
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(70),
                  child: Image.network(
                    patientImagePath ?? 'default_image_path',
                    width: 70,
                    height: 70,
                  ),
                ),
              ],
            ),

            smallBox,
            Text(
              Name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              date_time,
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.grey.shade600, fontSize: 12),
            ),
            IconButton(
              onPressed: () async {
                // Call the onDeletePressed callback if provided

                await client.auth.admin
                    .deleteUser(patientId);

                // If you want to delete the patient using Supabase, uncomment the line below
                // deletePatient(patientId);
              },

              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Future<List<Map<String, dynamic>>> fetchAllAppointments() async {

  try {
    final appointmentsResponse = await client
        .from('appointments')
        .select()
        .eq('status', 'upcoming');

    final patientsResponse = await client.from('profiles').select();
    final doctorsResponse = await client.from('doctors').select();

    List<Map<String, dynamic>> combinedData = [];

    for (var appointment in appointmentsResponse) {
      var patientInfo = patientsResponse.firstWhere(
            (patient) => patient['id'] == appointment['user_id'],
        orElse: () => {}, // Return null if patient not found
      );

      var doctorInfo = doctorsResponse.firstWhere(
            (doctor) => doctor['id'] == appointment['doctor_id'],
        orElse: () => {}, // Return null if doctor not found
      );

      if (patientInfo != null && doctorInfo != null) {
        Map<String, dynamic> combinedEntry = {
          'id': appointment['id'],
          'avatar_url_patient': patientInfo['avatar_url'] ?? 'No avatar url',
          'username': patientInfo['username'] ?? 'No username',
          'Phone_number': patientInfo['Phone_number'] ?? 'No phone number',
          'selected_time': appointment['selected_time'] ?? 'No time selected',
          'status': appointment['status'] ?? 'Upcoming',
          'selected_date': appointment['selected_date'] ?? 'No date selected',
          'doctor_name': doctorInfo['username'] ?? 'No doctor name',
          'avatar_url_doctor':doctorInfo['avatar_url']?? 'No avatar url',
          'specialty':doctorInfo['specialty']??' No specialty',
          // Add more doctor fields as needed
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

