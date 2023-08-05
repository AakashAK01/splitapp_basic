import 'package:flutter/material.dart';

import 'billsplitscreen.dart';

void main() {
  runApp(BillSplitApp());
}

class BillSplitApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bill Splitter',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BillSplitScreen(),
    );
  }
}
