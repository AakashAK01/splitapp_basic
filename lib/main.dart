import 'package:flutter/material.dart';

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

class BillSplitScreen extends StatefulWidget {
  @override
  _BillSplitScreenState createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  double _billAmount = 0;
  List<double> _percentages = [];
  int _numberOfFriends = 1;
  List<double> _friendShares = [];
  double _totalAmount = 0;

  void _calculateTotalAmount() {
    if (_formKey.currentState!.validate()) {
      double totalPercentage =
          _percentages.reduce((sum, percentage) => sum + percentage);
      if (totalPercentage != 100) {
        // Percentages should add up to 100%
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Percentage values should add up to 100%')),
        );
        return;
      }

      double totalAmountPerFriend = _billAmount / _numberOfFriends;

      setState(() {
        _totalAmount = _billAmount;
        _friendShares = List<double>.generate(_numberOfFriends, (index) {
          double individualShare =
              totalAmountPerFriend * (_percentages[index] / 100);
          _totalAmount -= individualShare;
          return individualShare;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('Bill Splitter')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Bill Amount (\$)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the bill amount';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _billAmount = double.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Number of Friends'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of friends';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _numberOfFriends = int.tryParse(value) ?? 1;
                    _percentages =
                        List.generate(_numberOfFriends, (index) => 0);
                  });
                },
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                itemCount: _numberOfFriends,
                itemBuilder: (context, index) {
                  return TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Percentage for Friend ${index + 1} (%)'),
                    onChanged: (value) {
                      setState(() {
                        _percentages[index] = double.tryParse(value) ?? 0;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateTotalAmount,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 20),
              Text('Total Amount: \₹${_totalAmount.toStringAsFixed(2)}'),
              if (_friendShares.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _numberOfFriends,
                    (index) {
                      return Text(
                        'Friend ${index + 1} Share: \₹${_friendShares[index].toStringAsFixed(2)}',
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
