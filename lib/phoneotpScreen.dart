import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:splitwise_basic/signup_screen.dart';
import 'package:splitwise_basic/verify_otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  final auth = FirebaseAuth.instance;
  bool loading = false;

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passWordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passWordController.dispose();
  }

  void phoneLogin() {
    setState(() {
      loading = true;
    });
    print(phoneNumberController.text);

    auth.verifyPhoneNumber(
        phoneNumber: '+91' + phoneNumberController.text,
        verificationCompleted: (_) {
          setState(() {
            loading = false;
          });
        },
        verificationFailed: (_) {
          const snackdemo = SnackBar(
            content: Text('Error Bro'),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackdemo);
          setState(() {
            loading = false;
          });
        },
        codeSent: (String verificationId, int? token) {
          setState(() {
            loading = false;
          });
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyOtpScreen(
                        verificationId: verificationId,
                      )));
        },
        codeAutoRetrievalTimeout: (e) {
          const snackdemo = SnackBar(
            content: Text('Time Out'),
            elevation: 10,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(5),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackdemo);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 90, 16, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/login.json',
                height: 300,
                width: 200,
                repeat: false,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  helperText: "Enter your phone number",
                  labelText: 'Phone Number',
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        phoneLogin();
                      },
                      child: const Text('Send OTP'),
                    ),
              const SizedBox(height: 10),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("Don't have an account?"),
              //     InkWell(
              //       onTap: () {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) => SignUpScreen()));
              //       },
              //       child: Text(
              //         "Sign up",
              //         style: TextStyle(color: Colors.blueAccent),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
