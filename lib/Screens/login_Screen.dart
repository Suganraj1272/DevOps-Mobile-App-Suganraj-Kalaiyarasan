// ignore_for_file: avoid_unnecessary_containers, avoid_print

import 'dart:convert';
import 'package:devops/Biometric%20Authentication/auth_service.dart';
import 'package:devops/Custom_Colors/Custom_Colors.dart';
import 'package:devops/Custom_Widgets/custom_Widget.dart';
import 'package:devops/Screens/dashboard_Screen.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  // login screen with email/password and biometric authentication//..
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false; // the toggling password visibility...//
  bool isChecked = false;
  bool obscurePassword = true;

  Future<void> login(String email, String password) async { // login api call//
    try {
      final response = await http.post(
        Uri.parse('https://dev-devops.haroob.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();// if login is successful, store user data..//
        final decoded = jsonDecode(response.body);
        final token = decoded['result']['token'];
        final userId = decoded['result']['user']['id'].toString();

        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        await prefs.setString('access_token', token);
        await prefs.setString('password', password);
        await prefs.setString('user_id', userId);

        print(userId);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),  // Navigate to dashboard screen//
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar( // Show error if credentials are incorrect//
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Must be at least 6 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  void _togglePasswordVisibility() {  // toggle visibility of password text..//
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }


  Future<void> _login() async { // Validate form and  login//
    if (formKey.currentState!.validate()) {
      await login(emailController.text.trim(), passwordController.text.trim());
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Container(  // Background header section with animations//
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.png'),
                          fit: BoxFit.fill)),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        left: 30,
                        width: 80,
                        height: 200,
                        child: FadeInUp(
                            duration: Duration(seconds: 1),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-1.png'))),
                            )),
                      ),
                      Positioned(
                        left: 140,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1200),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png'))),
                            )),
                      ),
                      Positioned(
                        right: 40,
                        top: 40,
                        width: 80,
                        height: 150,
                        child: FadeInUp(
                            duration: Duration(milliseconds: 1300),
                            child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            )),
                      ),
                      Positioned(
                        child: FadeInUp(
                          duration: Duration(milliseconds: 1600),
                          child: Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "DevOps",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Text(
                  "Login",
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Login to stay connected.",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                SizedBox(
                  height: 37,
                ),
                CustomTextFormField(// Email input field//
                  validator: validateEmail,
                  controller: emailController,
                  labelText: 'Email',
                ),
                SizedBox(
                  height: 30,
                ),
                CustomTextFormField(   // Password input field with toggle icon//
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  labelText: 'Password',
                ),
                SizedBox(
                  height: 10,
                ),
                SignInButton(onPressed: _login),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignInButton extends StatelessWidget {//         sign in button with biometric authentication//
  final VoidCallback onPressed;

  const SignInButton({super.key, required this.onPressed});

  Future<void> login( //                                         login function used with biometrics//
      BuildContext context, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://dev-devops.haroob.com/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('email', email);
        await prefs.setString('password', password);
        await prefs.setString(
            'access_token', jsonDecode(response.body)['result']['token']);

        await prefs.setString('user_id',
            jsonDecode(response.body)['result']['user']['id'].toString());
        debugPrint(
            jsonDecode(response.body)['result']['user']['id'].toString());

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          FadeInUp(    // Sign in button with animation//
              duration: Duration(milliseconds: 1900),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: GestureDetector(
                  onTap: onPressed,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                            colors: [AppColors.AppBar, AppColors.AppBar1])),
                    child: Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )),
          IconButton(
              onPressed: () async {  // Biometric authentication icon//
                bool check = await AuthService().authenticateLocally();
                if (check) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  String? email = prefs.getString('email');
                  String? password = prefs.getString('password');
                  if (email != null && password != null) {
                    await login(context, email, password);
                  }
                }
              },
              icon: Icon(
                Icons.fingerprint,
                color: Color.fromRGBO(82, 88, 189, 0.6),
                size: 60,
              )),
        ],
      ),
    );
  }
}
