import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:splitwise_basic/home_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, required this.verificationId});
  final String verificationId;
  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final auth = FirebaseAuth.instance;
  TextEditingController verifyOtpController = TextEditingController();
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image.asset(
            //   'assets/logo.png', // Replace with your logo image
            //   height: 100,
            //   width: 100,e
            // ),
            const SizedBox(height: 20),

            const SizedBox(height: 20),
            TextFormField(
              controller: verifyOtpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                hintText:
                    'Enter six digit OTP', // Change the country code as needed
              ),
            ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        loading = true;
                      });

                      print(verifyOtpController.text);
                      final credential = PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: verifyOtpController.text.toString());

                      try {
                        await auth.signInWithCredential(credential);
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false);
                      } catch (e) {
                        setState(() {
                          loading = false;
                          Fluttertoast.showToast(
                              msg: e.toString(),
                              textColor: Colors.white,
                              fontSize: 16.0);
                        });
                      }
                    },
                    child: const Text('Verify OTP'),
                  ),
          ],
        ),
      ),
    );
  }
}
