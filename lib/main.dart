import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'opening screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(BillSplitApp());
}

class BillSplitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: OpenScreen(),
    );
  }
}
