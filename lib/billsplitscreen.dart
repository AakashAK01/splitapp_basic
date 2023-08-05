import 'package:flutter/material.dart';

class BillSplitScreen extends StatefulWidget {
  @override
  _BillSplitScreenState createState() => _BillSplitScreenState();
}

class _BillSplitScreenState extends State<BillSplitScreen> {
  final _formKey = GlobalKey<FormState>();
  double _billAmount = 0;
  List<double> _percentages = [];
  int _numberOfFriends = 0;
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
        FocusScope.of(context).unfocus();
        return;
      }

      setState(() {
        _friendShares = List<double>.generate(_numberOfFriends, (index) {
          double individualShare = _billAmount * (_percentages[index] / 100);
          return individualShare;
        });

        _totalAmount = _friendShares.reduce((sum, share) => sum + share);
      });
    }
    FocusScope.of(context).unfocus();
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
          child: ListView(
            children: [
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Bill Amount (\$)',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  hintText: 'Enter your bill amount',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  prefixIcon:
                      Icon(Icons.attach_money_rounded, color: Colors.grey[500]),
                ),
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
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Number of friends',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  hintText: 'Enter number of shares',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  ),
                  prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of friends';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _numberOfFriends = int.tryParse(value) ?? 0;
                    _percentages =
                        List.generate(_numberOfFriends, (index) => 0);
                  });
                },
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _numberOfFriends,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Friend ${index + 1}',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          hintText:
                              'Enter percentage for ${index + 1}${(index == 0 ? "st" : (index == 1) ? "nd" : (index == 2) ? "rd" : "th")} friend',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide:
                                BorderSide(color: Colors.blue, width: 2.0),
                          ),
                          prefixIcon:
                              Icon(Icons.percent, color: Colors.grey[500]),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _percentages[index] = double.tryParse(value) ?? 0;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculateTotalAmount,
                child: const Text('Calculate'),
              ),
              const SizedBox(height: 20),
              Text('Total Amount: ₹${_totalAmount.toStringAsFixed(2)}'),
              if (_friendShares.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    _numberOfFriends,
                    (index) {
                      return Text(
                        'Friend ${index + 1} Share: ₹${_friendShares[index].toStringAsFixed(2)}',
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
