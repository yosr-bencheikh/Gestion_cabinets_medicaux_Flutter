import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hcaptcha/hcaptcha.dart';
import 'ForgotPassword.dart';
import 'adminPanel.dart';
import 'constants.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isloading = false;
  Future<bool> isAdmin(String userId) async {
    try {
      // Check if there is any user with the given userId and role 'admin'
      final response = await client.from('profiles').select('id').eq('id', userId).eq('role', 'admin').single();

      // If response is not null, then the user with the given userId has the admin role
      return response != null;
    } catch (error) {
      // Log the error for debugging purposes
      print('Error in isAdmin: $error');
      return false;
    }
  }

  Future<String?> userLogin({
    required final String email,
    required final String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(password: password, email: email);

      final user = response.user;
      return user?.id;
    } catch (error) {
      // Handle errors by showing an error message
      context.showErrorMessage('Invalid email or password. Please try again.');
      return null;
    }
  }
  void initState(){
    super.initState();
    HCaptcha.init(siteKey: '7dcc9377-6468-4671-9b6c-756be0a42802');

    
  }

  @override
  Widget build(BuildContext context) {
    Map? captchaDetails;
    return Scaffold(

      body:SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
            Image.asset(
            'images/doctor.jpg',
            ),
              SizedBox(height:40,),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              Row(
                children: [
                  Text('Forgot Password ?',style:TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return ForgotPassword();
                      }));// Replace '/signup' with the actual route for sign-up
                    },
                    child: Text(
                      "change Password",
                      style: TextStyle(color: prColor),
                    ),),

                ],
              ),

              const SizedBox(height: 32.0),




              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isloading = true;
                  });

                  dynamic loginValue = await userLogin(email: _emailController.text, password: _passwordController.text);

                  setState(() {
                    isloading = false;
                  });

                  if (loginValue != null) {
                    bool isDoctorUser = await isDoctor(loginValue);
                    bool isAdminUser = await isAdmin(loginValue);

                    if (isDoctorUser) {
                      Navigator.pushReplacementNamed(context, '/interfacedoctor');
                    } else if (isAdminUser) {
                      Navigator.push(
                      context, MaterialPageRoute(builder: (context) => AdminPanel()));
                      }// Change '/adminpanel' to the actual route for the admin panel
                     else {
                      Navigator.pushReplacementNamed(context, '/interfaceclient');
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Login Failed'),
                        content: Text('Invalid email or password. Please try again.'),
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
                },
                style: ElevatedButton.styleFrom(
                  primary: prColor, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Login'),
              ),
          SizedBox(height: 10,),
          Text("Don't have an account?",style: TextStyle(color: Colors.grey),),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/signup'); // Replace '/signup' with the actual route for sign-up
            },
            child: Text(
              "Sign Up",
              style: TextStyle(color: prColor),
            ),

          ),



            ],
          ),
        ),
      ),
    );
  }
}

extension ShowErrorMessage on BuildContext {
  void showErrorMessage(String message) {
    showDialog(
      context: this,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
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
}
Future<bool> isDoctor(String userId) async {
  try {
    // Check if there is any doctor with the given userId
    final response = await client.from('doctors').select('id').eq('id', userId).single();

    // If response is not null, then the doctor with the given userId exists
    if (response != null) {

      return true;
    } else {
      return false;
    }
  } catch (error) {
    // Log the error for debugging purposes
    print('Error in isDoctor: $error');
    return false;
  }
}






