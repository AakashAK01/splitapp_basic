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
  List<String> _friendShareValues = [];
  void _calculateTotalAmount() {
    if (_formKey.currentState!.validate()) {
      double totalPercentage = 0;
      for (int i = 0; i < _percentages.length; i++) {
        double percentage = _percentages[i];
        totalPercentage += percentage;
      }
      if (totalPercentage != 100) {
        _showAlertDialog(context, 'Percentage values should add up to 100%');
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

  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: _numberOfFriends == 0 ? 300 : 500,
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.fromLTRB(25, 50, 25, 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text("SPLITWISE",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w500)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(fontSize: 40, color: Colors.black),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 40.0),
                              hintText: 'Amount',
                              hintStyle: TextStyle(
                                  color: Colors.black45, fontSize: 25),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 4),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 4),
                              ),
                              prefixIcon: Icon(
                                Icons.attach_money_rounded,
                                color: Colors.black,
                                size: 35,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "0") {
                                return 'Enter bill amount';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _billAmount = double.tryParse(value) ?? 0;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                        Expanded(
                          child: TextFormField(
                            style: TextStyle(fontSize: 40, color: Colors.black),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 40.0),
                              hintText: 'Friends',
                              hintStyle: TextStyle(
                                  color: Colors.black45, fontSize: 25),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 4),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 4),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 35,
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value == "0") {
                                return 'Enter the number of friends';
                              }
                              final int parsedValue = int.tryParse(value) ?? 0;
                              if (parsedValue > 15) {
                                return 'Maximum number of friends is 15';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _numberOfFriends = int.tryParse(value) ?? 0;
                                _percentages = List.generate(
                                    _numberOfFriends, (index) => 0);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: _numberOfFriends,
                        itemBuilder: (context, index) {
                          if (_friendShareValues.length <= index) {
                            _friendShareValues.add('');
                          }
                          return Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  labelText:
                                      '${index + 1}${(index == 0 ? "st" : (index == 1) ? "nd" : (index == 2) ? "rd" : "th")} friend\'s share',
                                  labelStyle: TextStyle(color: Colors.black),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 12.0),
                                  hintText: 'Enter percentage',
                                  hintStyle: TextStyle(color: Colors.black45),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.black45, width: 1.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0),
                                  ),
                                  prefixIcon:
                                      Icon(Icons.percent, color: Colors.black),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _friendShareValues[index] = value;
                                    _percentages[index] =
                                        double.tryParse(value) ?? 0;
                                  });
                                },
                                initialValue: _friendShareValues[index],
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                children: [
                  Text(
                    'Total Amount: ₹${_totalAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(height: 10),
                  if (_friendShares.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        _numberOfFriends,
                        (index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Friend ${index + 1} Share: ₹${_friendShares[index].toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                height: 10,
                              )
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 30),
        child: InkWell(
          onTap: () {
            _calculateTotalAmount();
          },
          child: Container(
            width: 328,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            child: Center(
              child: Text(
                "Split Amount",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
