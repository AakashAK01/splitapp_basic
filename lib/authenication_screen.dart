import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:splitwise_basic/Utils/utils.dart';
import 'package:splitwise_basic/home_screen.dart';
import 'package:splitwise_basic/phoneotpScreen.dart';
import 'package:splitwise_basic/signup_screen.dart';
import 'package:splitwise_basic/verify_otp_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'Utils/language_picker.dart';

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final auth = FirebaseAuth.instance;
  bool loading = false;

  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passWordController = TextEditingController();
  bool isListening = false;
  String? text;
  SpeechToText speechToText = SpeechToText();

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

  void emailLogin() {
    setState(() {
      loading = true;
    });
    auth
        .signInWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passWordController.text.toString())
        .then((value) {
      setState(() {
        loading = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    }).onError((e, stackTrace) {
      setState(() {
        loading = false;
      });
      Utils().toastMessage(e.toString());
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.email,
                        helperText: AppLocalizations.of(context)!.eg +
                            "abc124@example.com",
                        labelText: AppLocalizations.of(context)!.email,
                      ),
                    ),
                  ),
                  // AvatarGlow(
                  //   repeatPauseDuration: Duration(seconds: 2),
                  //   animate: isListening,
                  //   curve: Curves.decelerate,
                  //   glowColor: Colors.grey,
                  //   endRadius: 30,
                  //   child: IconButton(
                  //     icon: Icon(Icons.mic),
                  //     onPressed: () async {
                  //       setState(() {
                  //         isListening = true;
                  //       });

                  //       bool available = await speechToText.initialize();
                  //       if (available) {
                  //         speechToText.listen(
                  //           onResult: (result) {
                  //             setState(() {
                  //               text = result.recognizedWords;
                  //             });
                  //           },
                  //           onSoundLevelChange: (level) {
                  //             // You can add sound level visualization here
                  //           },
                  //         );
                  //       }
                  //     },
                  
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passWordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.password,
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        emailLogin();
                      },
                      child: Text(
                        AppLocalizations.of(context)!.login,
                      ),
                    ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.dont_have_acc),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()));
                    },
                    child: Text(
                      AppLocalizations.of(context)!.sign_up,
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PhoneNumberScreen()));
                },
                child: Text(
                  AppLocalizations.of(context)!.login_with_number,
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
              SizedBox(height: 10),
              LanguageWidget()
            ],
          ),
        ),
      ),
    );
  }
}
