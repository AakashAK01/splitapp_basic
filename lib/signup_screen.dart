import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:splitwise_basic/Utils/utils.dart';
import 'package:splitwise_basic/authenication_screen.dart';
import 'package:splitwise_basic/verify_otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final CollectionReference _user =
      FirebaseFirestore.instance.collection('users');
  final auth = FirebaseAuth.instance;
  bool loading = false;

  final phoneNumberController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passWordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passWordController.dispose();
  }

  Future<void> login() async {
    setState(() {
      loading = true;
    });
    auth
        .createUserWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passWordController.text.toString())
        .then((value) {
      setState(() {
        loading = false;
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Authentication()));
      });
      create();
    }).onError((e, stackTrace) {
      Utils().toastMessage(e.toString());
      setState(() {
        loading = false;
      });
    });
    print("Done");
  }

  Future<void> create() async {
    await _user.add({
      "phone": phoneNumberController.text.toString(),
      "name": nameController.text.toString(),
      "usertype": "admin",
      "email": emailController.text.toString()
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
                'assets/signup.json',
                height: 300,
                width: 200,
                repeat: false,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: "Name",
                  labelText: 'Name',
                ),
              ),
              TextFormField(
                controller: phoneNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter your Phone Number",
                  labelText: 'Phone Number',
                ),
              ),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                  helperText: "Eg: abc124@example.com",
                  labelText: 'Email',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: passWordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              const SizedBox(height: 20),
              loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () {
                        login();
                      },
                      child: const Text('Sign up'),
                    ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
