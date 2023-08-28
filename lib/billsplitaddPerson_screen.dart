import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splitwise_basic/group_screen.dart';

class BillSplitScreenAddFeature extends StatefulWidget {
  BillSplitScreenAddFeature({this.id, this.index, this.type});
  String? id;
  int? index;
  String? type;
  @override
  _BillSplitScreenAddFeatureState createState() =>
      _BillSplitScreenAddFeatureState();
}

class _BillSplitScreenAddFeatureState extends State<BillSplitScreenAddFeature> {
  final CollectionReference _group =
      FirebaseFirestore.instance.collection('group');
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? name;
  String? total;
  String? share1;
  String? share2;
  String? share3;
  double _billAmount = 0;
  String? imageUrl;
  XFile? file;
  String? filePath;
  List<double> _percentages = [];
  int _numberOfFriends = 0;
  List<double> _friendShares = [];
  double _totalAmount = 0;
  List<String> _friendShareValues = [];
  List<String> _friendemailList = [];

  @override
  void initState() {
    print("Bill Screen${widget.id}Index:${widget.index}");

    super.initState();
  }

  void _calculateTotalAmount() {
    print(widget.type);
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
        widget.type != "ad" ? _create() : ();
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

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages =
        referenceRoot.child('avatar'); // Reference to storage root

    Reference referenceImageToUpload = referenceDirImages
        .child(uniqueFileName); // Reference for image to stored

    await referenceImageToUpload.putFile(File(file!.path));

    imageUrl = await referenceImageToUpload.getDownloadURL();
    List<String> friendShares = [];
    for (int i = 0; i < _numberOfFriends; i++) {
      friendShares.add(_friendShareValues[i]);
    }
    if (documentSnapshot != null) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      name = data['name'] ?? "";
      total = (data['total'] ?? 0);
      for (int i = 0; i < _numberOfFriends; i++) {
        share1 = (data['share$i'] ?? 0);
      }
    }
    Map<String, dynamic> updateData = {
      "total": _totalAmount.toString(),
      "imageurl": imageUrl,
      "path": filePath,
      "no of shares": _numberOfFriends
    };

    for (int i = 0; i < _numberOfFriends; i++) {
      updateData["share$i"] = _friendShares[i].toString();
      updateData["email$i"] = _friendemailList[i].toString();
    }

    await _group.doc(widget.id).update(updateData);
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupScreen(
                index: widget.index,
                type: widget.type,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: StreamBuilder(
          stream: _group.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[widget.index ?? 0];
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: _numberOfFriends == 0 ? 450 : 700,
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
                            height: 10,
                          ),
                          InkWell(
                              onTap: () async {
                                ImagePicker imagePicker = ImagePicker();
                                file = await imagePicker.pickImage(
                                    source: ImageSource.gallery);
                                print("${file?.path}");
                                setState(() {
                                  filePath = file?.path;
                                });
                                if (file == null) return;
                              },
                              child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: filePath != null
                                      ? FileImage(File(filePath ?? ""))
                                      : AssetImage('assets/default.png')
                                          as ImageProvider)),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 10.0),
                                    hintText: 'Enter Amount',
                                    hintStyle: TextStyle(
                                        color: Colors.black45, fontSize: 15),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 2),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.currency_rupee,
                                      color: Colors.black,
                                      size: 25,
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
                                      _percentages = List.generate(
                                          _numberOfFriends, (index) => 0);
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              hintText: 'Number of Persons (Max: 5)',
                              hintStyle: TextStyle(
                                  color: Colors.black45, fontSize: 15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide:
                                    BorderSide(color: Colors.black, width: 2),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 25,
                              ),
                            ),
                            validator: (value) {
                              int numberOfPersons =
                                  int.tryParse(value ?? '0') ?? 0;
                              if (numberOfPersons <= 0 || numberOfPersons > 5) {
                                return 'Enter a valid number of persons (1 to 5)';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _numberOfFriends = int.tryParse(value) ?? 0;
                                _numberOfFriends = _numberOfFriends.clamp(
                                    0, 5); // Limit to 1 to 5 persons
                                _percentages = List.generate(
                                    _numberOfFriends, (index) => 0);
                                _friendShareValues = List.generate(
                                    _numberOfFriends, (index) => '');
                              });
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Group name: ${documentSnapshot['name']}",
                            style: TextStyle(fontSize: 30, color: Colors.black),
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

                                if (_friendemailList.length <= index) {
                                  _friendemailList.add('');
                                }
                                return Column(
                                  children: [
                                    TextFormField(
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText:
                                            '${index + 1}${_getNumberSuffix(index + 1)} friend\'s share',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                        hintText: 'Enter percentage',
                                        hintStyle:
                                            TextStyle(color: Colors.black45),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.black45,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2.0),
                                        ),
                                        prefixIcon: Icon(Icons.percent,
                                            color: Colors.black),
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
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        labelText:
                                            '${index + 1}${_getNumberSuffix(index + 1)} friend\'s Email-ID',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0),
                                        hintText: 'Enter Email-ID',
                                        hintStyle:
                                            TextStyle(color: Colors.black45),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.black45,
                                              width: 1.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2.0),
                                        ),
                                        prefixIcon: Icon(Icons.percent,
                                            color: Colors.black),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _friendemailList[index] = value;
                                          // _percentages[index] =
                                          //     double.tryParse(value) ?? 0;
                                        });
                                      },
                                      initialValue: _friendemailList[index],
                                    ),
                                    const SizedBox(height: 23),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _friendShares.length,
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
            );
          }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 30),
        child: InkWell(
          onTap: () async {
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

  String _getNumberSuffix(int number) {
    if (number % 10 == 1 && number % 100 != 11) {
      return "st";
    } else if (number % 10 == 2 && number % 100 != 12) {
      return "nd";
    } else if (number % 10 == 3 && number % 100 != 13) {
      return "rd";
    } else {
      return "th";
    }
  }
}
