import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  State<PatientsPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patients' list"),
      ),

      body: Container(
        color: Colors.white, // Set the background color here
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0,right: 20.0),
          child: FutureBuilder<List<Map<String, dynamic>>?>(
            future: fetchAllPatients(),
            builder: (context, AsyncSnapshot<List<Map<String, dynamic>>?> doctorsSnapshot) {
              if (doctorsSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (doctorsSnapshot.hasError || doctorsSnapshot.data == null) {
                // Handle the error condition when fetching doctors data
                return Text('Error fetching patients data');
              } else {

                // Use ListView.builder to display the list of doctors
                return ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: doctorsSnapshot.data!.length,
                  itemBuilder: (context, index) {
                    // Check if the index is even or odd
                    bool isEvenIndex = index.isEven;

                    // For even index, create a new row
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
                                patientImagePath: patientData1['avatar_url'] ?? 'no image',
                                patientName: patientData1['username'] ?? 'No Name',
                                patientId: patientData1['id'],
                              ),
                            ),
                            Expanded(
                              child: PatientList(
                                patientImagePath: patientData2['avatar_url'],
                                patientName: patientData2['username'] ?? 'No Name',
                              patientId: patientData2['id']??'0',
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
  final String patientName;
  final String patientId; // Add patientId to uniquely identify each patient
  final VoidCallback? onDeletePressed;

  const PatientList({
    Key? key,
    required this.patientImagePath,
    required this.patientName,
    required this.patientId,
    this.onDeletePressed,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(70),
              child: Image.network(
                patientImagePath ?? 'default_image_path',
                width: 70,
                height: 70,
              ),
            ),
            smallBox,
            Text(
              patientName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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
Future<List<Map<String, dynamic>>?> fetchAllPatients() async {
  try {
    final response = await client.from('profiles').select();
    return response as List<Map<String, dynamic>>;
  } catch (error) {
    return null;
  }
}
