import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_basic/verify_otp_screen.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final auth = FirebaseAuth.instance;
  bool loading = false;
  TextEditingController phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Number Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image.asset(
            //   'assets/logo.png', // Replace with your logo image
            //   height: 100,
            //   width: 100,
            // ),
            SizedBox(height: 20),
            Text(
              'Enter your mobile number to get started',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91', // Change the country code as needed
              ),
            ),
            SizedBox(height: 20),
            loading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () {
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackdemo);
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
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackdemo);
                          });
                    },
                    child: Text('Send OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
