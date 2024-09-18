import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'DoctorList.dart';
import 'category.dart';
import 'constants.dart';

class InterfaceClient extends StatelessWidget {
  const InterfaceClient({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            smallBox,
            UserInfoCard(),
            smallBox,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Choose your doctor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                  Text('See all', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),)
                ],
              ),
            ),
            smallBox,
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: FutureBuilder<List<Map<String, dynamic>>?>(
                  future: fetchAllDoctors(),
                  builder: (context, AsyncSnapshot<List<Map<String, dynamic>>?> doctorsSnapshot) {
                    if (doctorsSnapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (doctorsSnapshot.hasError || doctorsSnapshot.data == null) {
                      // Handle the error condition when fetching doctors data
                      return Text('Error fetching doctors data');
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
                              final doctorData1 = doctorsSnapshot.data![index];
                              final doctorData2 = doctorsSnapshot.data![nextIndex];

                              return Row(
                                children: [
                                  DoctorList(
                                    rating: 4,
                                    doctorImagePath: doctorData1['avatar_url'],
                                    doctorName: doctorData1['username'] ?? 'No Name',
                                    doctorProfession: doctorData1['specialty'] ?? 'No specialty',
                                    doctorExperienceYears: doctorData1['experience'] ?? 'No experience',
                                    doctorHospital: doctorData1['hospital_name'] ?? 'No hospital',
                                    doctorAddress: 'tunis',
                                    doctorPhone: doctorData1['Phone_number']?.toString() ?? 'No phone',
                                    doctorStudies: doctorData1['studies'] ?? 'No studies',
                                    doctorHours: '9am_6pm', doctorId: doctorData1['id'],
                                  ),
                                  DoctorList(
                                    rating: 4,
                                    doctorImagePath: doctorData2['avatar_url'],
                                    doctorName: doctorData2['username'] ?? 'No Name',
                                    doctorProfession: doctorData2['specialty'] ?? 'No specialty',
                                    doctorExperienceYears: doctorData2['experience'] ?? 'No experience',
                                    doctorHospital: doctorData2['hospital_name'] ?? 'No hospital',
                                    doctorAddress: 'tunis',
                                    doctorPhone: doctorData2['Phone_number']?.toString() ?? 'No phone',
                                    doctorStudies: doctorData2['studies'] ?? 'No studies',
                                    doctorHours: '9am_6pm', doctorId: doctorData2['id'],
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
      future: fetchUserData('avatar_url', 'profiles'),
      builder: (context, AsyncSnapshot<String?> imageUrlSnapshot) {
        if (imageUrlSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (imageUrlSnapshot.hasError || imageUrlSnapshot.data == null) {
          // Handle the error condition when fetching image URL
          return Text('Error fetching image URL');
        } else {
          return FutureBuilder<String?>(
            future: fetchUserData('username', 'profiles'),
            builder: (context, AsyncSnapshot<String?> usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (usernameSnapshot.hasError || usernameSnapshot.data == null) {
                // Handle the error condition when fetching username
                return Text('Error fetching username');
              } else {
                return Container(
                  height: screenHeight * 0.35,
                  width: double.infinity,
                  child: Card(
                    color: prColor,
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.waving_hand),
                          title: Text("Hello"),
                          subtitle: Text(
                            usernameSnapshot.data!,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          trailing: Container(
                            width: 60,
                            height: 60,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(70),
                              child: Image.network(
                                imageUrlSnapshot.data!,
                                fit: BoxFit.cover,
                                width: 70,height: 70,
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
                        smallBox,
                        Text('Specialties', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        smallBox,
                        Container(
                          height: 60,
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchSpecialties(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError || !snapshot.hasData) {
                                return Text('Error fetching specialties');
                              } else {
                                final List<Map<String, dynamic>> specialties = snapshot.data!;
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: specialties.length,
                                  itemBuilder: (context, index) {
                                    final specialty = specialties[index];
                                    return Category(iconImagePath: specialty['icon_path'], categoryName: specialty['name']);
                                  },
                                );
                              }
                            },
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

Future<String?> fetchUserData(String col, String table) async {
  try {
    final userData = await client
        .from(table)
        .select(col)
        .eq('id', client.auth.currentUser!.id)
        .single();

    return userData[col] as String?;
  } catch (error) {
    return null;
  }
}

Future<List<Map<String, dynamic>>?> fetchAllDoctors() async {
  try {
    final response = await client
        .from('doctors')
        .select();

    return response as List<Map<String, dynamic>>;
  } catch (error) {
    return null;
  }
}

Future<List<Map<String, dynamic>>> fetchSpecialties() async {
  try {
    final response = await client.from('specialty').select();

    return response.map<Map<String, dynamic>>((specialty) {
      return {
        'name': specialty['name'] as String,
        'icon_path': specialty['icon_path'] as String,
      };
    }).toList();
  } catch (error) {
    print('Error fetching specialties: $error');
    return []; // Return an empty list in case of error
  }
}

