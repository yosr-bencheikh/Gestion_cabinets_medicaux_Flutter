import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ImageUpload.dart';
import 'constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _doctorSpecialtyController = TextEditingController();
  final TextEditingController _doctorExperienceController = TextEditingController();
  final TextEditingController _doctorStudiesController = TextEditingController();
  final TextEditingController _doctorHospitalController = TextEditingController();

  String? _imageUrl;
  var _loading = true;
  String? _selectedUserType;
  String? _selectedDoctorStatus;
  String? _doctorSpecialty;
  String? _doctorExperience;
  String? _doctorStudies;
  String? _hospitalName;

  Future<bool?> createUser({
    required final String email,
    required final String password,
  }) async {
    try {
      await client.auth.signUp(
        email: email,
        password: password,
      );
      return true;
    } catch (error) {
      print('Error during sign up: $error');
      return false;
    }
  }

  Future<void> _updateProfile() async {
    setState(() {
      _loading = true;
    });

    final userName = _nameController.text.trim();
    final phoneNumber = int.tryParse(_phoneController.text.trim()) ?? 0;
    final user = client.auth.currentUser;
    final specialty = _doctorSpecialtyController.text;
    final experience = _doctorExperienceController.text;
    final studies = _doctorStudiesController.text;
    final hospital = _doctorHospitalController.text;

    try {
      if (_selectedUserType == 'client' && user != null) {
        // Update the 'profiles' table for clients
        final updates = {
          'id': user.id,
          'username': userName,
          'Phone_number': phoneNumber,
          'avatar_url': _imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        };

        print('Updating client profile with: $updates');
        await client.from('profiles').upsert(updates);
      } else if (_selectedUserType == 'doctor' && user != null) {
        // Update the 'doctors' table for doctors
        final doctorUpdates = {
          'id': user.id,
          'username': userName,
          'Phone_number': phoneNumber,
          'specialty': specialty,
          'experience': experience,
          'studies': studies,
          'hospital_name': hospital,
          // Add other doctor attributes as needed
        };

        print('Updating doctor profile with: $doctorUpdates');
        await client.from('doctors').upsert(doctorUpdates);
      }

      if (mounted) {
        context.showSuccessMessage('Successfully updated profile!');
      }
    } on PostgrestException catch (error) {
      print('PostgrestException: ${error.message}');
      context.showErrorMessage('Failed to update profile. Please try again.');
    } catch (error) {
      print('Unexpected error: $error');
      context.showErrorMessage('Unexpected error occurred. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  final _formKey = GlobalKey<FormState>(); // Form key for form validation

  // Validators
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    // Check if the entered name is a number
    if (double.tryParse(value) != null) {
      return 'Name cannot be a number';
    }

    // Check if the entered name is a single long alphabet
    if (value.length <=2) {
    return "You must enter a longer name";
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length !=8) {
      return "a phone number must contain 8 numbers";
    }
    // Additional validation can be added here if needed
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length <6) {
      return "You must enter a longer password";
    }
    // Additional validation can be added here if needed
    return null;
  }
  String? _validateSpecialty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Specialty is required';
    }
    if (!['Cardiology', 'General', 'Pulmonology', 'Genecology', 'Ophthalmology', 'Dental', 'Neurology'].contains(value)) {
      return "This specialty is not available yet";
    }

    // Additional validation can be added here if needed
    return null;
  }
  String? _validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Experience is required';
    }
    if (value.length>2 ) {
      return "Enter a valid number";
    }
    // Additional validation can be added here if needed
    return null;
  }
  String? _validateStudies(String? value) {
    if (value == null || value.isEmpty) {
      return 'Studies is required';
    }
    if (double.tryParse(value) != null) {
      return "Studies can't be a number";
    }
    // Additional validation can be added here if needed
    return null;
  }
  String? _validateHospital(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hospital name is required';
    }
    if (double.tryParse(value) != null) {
      return "Hospital name is not a number";
    }
    // Additional validation can be added here if needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Assign the form key to the form widget
            child: Column(
              children: [
                smallBox,
                Avatar(
                  imageUrl: _imageUrl,
                  onUpload: (imageUrl) async {
                    setState(() {
                      _imageUrl = imageUrl!;
                    });
                  },
                ),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName, // Add validator for name field
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                  ),
                ),
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone, // Add validator for phone field
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                  ),
                ),
                TextFormField(
                  controller: _emailController,
                  validator: _validateEmail, // Add validator for email field
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                  ),
                ),
                TextFormField(
                  controller: _passwordController,
                  validator: _validatePassword, // Add validator for password field
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedUserType,
                  onChanged: (value) {
                    setState(() {
                      _selectedUserType = value;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'client',
                      child: Text('Client'),
                    ),
                    DropdownMenuItem(
                      value: 'doctor',
                      child: Text('Doctor'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'User Type',
                  ),
                ),
                if (_selectedUserType == 'doctor') ...[
                  TextFormField(
                    controller: _doctorSpecialtyController,
                    validator: _validateSpecialty,
                    decoration: InputDecoration(
                      labelText: 'Doctor Specialty',
                    ),
                  ),
                  TextFormField(
                    controller: _doctorExperienceController,
                    validator: _validateExperience,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Doctor Experience (in years)',
                    ),
                  ),
                  TextFormField(
                    controller: _doctorStudiesController,
                    validator: _validateStudies,
                    decoration: InputDecoration(
                      labelText: 'Doctor Studies',
                    ),
                  ),
                  TextFormField(
                    controller: _doctorHospitalController,
                    validator: _validateHospital,
                    decoration: InputDecoration(
                      labelText: 'Hospital name',
                    ),
                  ),
                ],
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    // Validate the form before proceeding
                    if (_formKey.currentState!.validate()) {
                      final userValue = await createUser(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (userValue == true) {
                        if (_selectedUserType == 'client') {
                          Navigator.pushReplacementNamed(context, '/interfaceclient');
                        } else if (_selectedUserType == 'doctor') {
                          Navigator.pushReplacementNamed(context, '/interfacedoctor');
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Sign Up Failed'),
                            content: Text('Invalid entry. Please try again.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      await _updateProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: prColor, // Background color
                    onPrimary: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension ShowSuccessMessage on BuildContext {
  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green, // Customize the background color
      ),
    );
  }
}
extension ShowErrorMessage on BuildContext {
  void showErrorMessage(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red, // Customize the background color
      ),
    );
  }
}
