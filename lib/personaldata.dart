import 'package:flutter/material.dart';
import 'ImageUpload.dart';
import 'constants.dart';
import 'package:flutter/services.dart'; // Add this import for input formatters

class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({Key? key}) : super(key: key);

  @override
  _PersonalDataPageState createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController studiesController = TextEditingController();
  TextEditingController specialtyController = TextEditingController();
  TextEditingController experienceController = TextEditingController();

  String? _imageUrl;

  late String userId; // Declare userId variable

  Future<bool> isDoctor(String userId) async {
    try {
      print('Checking if user is a doctor with ID: $userId');
      final response = await client.from('doctors').select('id').eq('id', userId).single();
      print('Response from database: $response');
      return response != null;
    } catch (error) {
      print('Error in isDoctor: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      Map<String, dynamic> userProfileData = {};

      // Check if the user is a doctor
      bool isDoctorUser = await isDoctor(userId);

      if (isDoctorUser) {
        final doctorResponse = await client.from('doctors').select().eq('id', userId).single();
        userProfileData.addAll(doctorResponse as Map<String, dynamic>);
      } else {
        final profileResponse = await client.from('profiles').select().eq('id', userId).single();
        userProfileData.addAll(profileResponse as Map<String, dynamic>);
      }

      return userProfileData;
    } catch (error) {
      print('Error fetching user profile: $error');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    userId = client.auth.currentUser!.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error fetching user profile');
            } else {
              Map<String, dynamic> userProfileData = snapshot.data!;
              userId = client.auth.currentUser!.id;

              return Column(
                children: <Widget>[
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    child: Card(
                      color: prColor,
                      child: Avatar(
                        imageUrl: _imageUrl,
                        onUpload: (imageUrl) async {
                          setState(() {
                            _imageUrl = imageUrl;
                          });

                          if (await isDoctor(userId)) {
                            await client
                                .from('doctors')
                                .update({'avatar_url': imageUrl})
                                .eq('id', userId);
                          } else {
                            await client
                                .from('profiles')
                                .update({'avatar_url': imageUrl})
                                .eq('id', userId);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: TextField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          labelText: 'User name',
                          hintText: userProfileData['username'] ??
                              'Enter your user name',
                        ),
                      ),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: TextField(
                        controller: phoneController ,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly, // Allow only digits
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          hintText: userProfileData['Phone_number']
                              .toString() ?? 'Enter your phone number',
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      updateProfile(userProfileData);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: prColor,
                      onPrimary: Colors.white,
                      padding: EdgeInsets.symmetric(
                          horizontal: 100, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Edit profile'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void updateProfile(Map<String, dynamic> oldProfileData) async {
    String newUserName = userNameController.text.trim();
    String phoneText = phoneController.text.trim();
    int newPhone;

    // Check if the phoneText is empty or not a valid number
    if (phoneText.isNotEmpty) {
      try {
        newPhone = int.parse(phoneText);
      } catch (e) {
        print('Error parsing phone number: $e');
        // Handle the error (e.g., show a message to the user)
        return;
      }
    } else {
      // If the phone number field is empty, keep the old value
      newPhone = oldProfileData['Phone_number'];
    }

    bool isDoctorUser = await isDoctor(userId);

    final avatarUrl = _imageUrl ?? oldProfileData['avatar_url'];

    print('Updating profile...');

    if (isDoctorUser) {
      await client.from('doctors').update({
        'username': newUserName,
        'Phone_number': newPhone,
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    } else {
      await client.from('profiles').update({
        'username': newUserName,
        'Phone_number': newPhone,
        'avatar_url': avatarUrl,
      }).eq('id', userId);
    }

    print('Profile updated successfully.');

    setState(() {
      oldProfileData['username'] = newUserName;
    });
  }}
