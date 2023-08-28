import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:splitwise_basic/billsplitscreen.dart';
import 'package:splitwise_basic/home_screen.dart';

class GroupScreen extends StatefulWidget {
  GroupScreen({super.key, this.index,  this.type});
  int? index;
  String? type;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  String? imageUrl;
  XFile? file;
  String? filePath;
  bool editClicked = false;
  List<double> shareamounts = [];
  List<double> sharePercentages = [];
  List<TextEditingController> shareControllers = [];
  int no_of_share = 0;
  final CollectionReference _group =
      FirebaseFirestore.instance.collection('group');
  Future<void> _delete(String groupID) async {
    Navigator.pop(context);
    await _group.doc(groupID).delete();
  }

  Future<void> _deleteImage(
      String url, DocumentSnapshot documentSnapshot) async {
    //Navigator.pop(context);
    Reference storageReference = FirebaseStorage.instance.refFromURL(url);
    await storageReference.delete();
  }

  void _showEditDialog(DocumentSnapshot documentSnapshot) {
    int numberOfShares = documentSnapshot['no of shares'];
    shareamounts = List.generate(numberOfShares, (index) {
      String shareKey = 'share$index';
      return double.parse(documentSnapshot[shareKey] ?? '0');
    });

    shareamounts.forEach((amount) {
      print(amount);
    });

    double totalAmount = double.parse(documentSnapshot['total']);

    sharePercentages = List.generate(numberOfShares, (index) {
      return (shareamounts[index] / totalAmount) * 100;
    });
    print(sharePercentages[1]);
    // double share1Amount = double.parse(documentSnapshot['share1']);
    // double share2Amount = double.parse(documentSnapshot['share2']);
    // double share3Amount = double.parse(documentSnapshot['share3']);

    // double share1Percentage = (share1Amount / totalAmount) * 100;
    // double share2Percentage = (share2Amount / totalAmount) * 100;
    // double share3Percentage = (share3Amount / totalAmount) * 100;
    TextEditingController totalController =
        TextEditingController(text: totalAmount.toStringAsFixed(2));
    for (int i = 0; i < sharePercentages.length; i++) {
      shareControllers.add(TextEditingController(
        text: sharePercentages[i].toStringAsFixed(2),
      ));
    }
    // TextEditingController share1Controller =
    //     TextEditingController(text: share1Percentage.toStringAsFixed(2));
    // TextEditingController share2Controller =
    //     TextEditingController(text: share2Percentage.toStringAsFixed(2));
    // TextEditingController share3Controller =
    //     TextEditingController(text: share3Percentage.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update'),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      filePath == null
                          ? CircleAvatar(
                              backgroundImage: documentSnapshot['imageurl'] !=
                                      null
                                  ? NetworkImage(documentSnapshot['imageurl'])
                                  : NetworkImage(
                                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
                                      as ImageProvider,
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundImage: FileImage(
                                  File(filePath ?? "")) // Explicit type casting
                              ),
                      SizedBox(width: 15),
                      InkWell(
                        onTap: () async {
                          ImagePicker imagePicker = ImagePicker();
                          file = await imagePicker.pickImage(
                              source: ImageSource.gallery);
                          print("${file?.path}");
                          setState(() {
                            filePath = file?.path;
                            editClicked = true;
                          });
                          if (file == null) return;

                          String uniqueFileName =
                              DateTime.now().millisecondsSinceEpoch.toString();

                          Reference referenceRoot =
                              FirebaseStorage.instance.ref();
                          Reference referenceDirImages = referenceRoot
                              .child('avatar'); // Reference to storage root

                          Reference referenceImageToUpload =
                              referenceDirImages.child(
                                  uniqueFileName); // Reference for image to stored

                          await referenceImageToUpload
                              .putFile(File(file!.path));

                          setState(() async {
                            imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                          });
                        },
                        child: Icon(Icons.edit,
                            color: const Color.fromARGB(255, 78, 77, 77),
                            size: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     _deleteImage(
                      //         documentSnapshot["imageurl"], documentSnapshot);
                      //   },
                      //   child: Icon(Icons.delete,
                      //       color: const Color.fromARGB(255, 78, 77, 77),
                      //       size: 20),
                      // ),
                    ],
                  ),
                  TextFormField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Total Amount'),
                  ),
                  for (int i = 0; i < numberOfShares; i++)
                    TextFormField(
                      controller: shareControllers[i],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Share by Person ${i + 1}(%)'),
                    ),
                ],
              ),
            );
          }),
          actions: [
            ElevatedButton(
              onPressed: () async {
                double newTotal = double.tryParse(totalController.text) ?? 0;
                List<double> newSharePercentages = [];
                for (var controller in shareControllers) {
                  double percentage = double.tryParse(controller.text) ?? 0;
                  newSharePercentages.add(percentage);
                }

                List<double> newShareAmounts =
                    List.generate(numberOfShares, (index) {
                  return (newSharePercentages[index] / 100) * newTotal;
                });

                _deleteImage(documentSnapshot['imageurl'], documentSnapshot);

                Map<String, dynamic> newData = {
                  'total': newTotal.toString(),
                  'imageurl': imageUrl,
                };

                for (int i = 0; i < newShareAmounts.length; i++) {
                  String shareKey = 'share$i';
                  newData[shareKey] = newShareAmounts[i].toString();
                }

                _group.doc(documentSnapshot.id).update(newData);

                print(imageUrl);

                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  filePath = null;
                });

                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
               Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
            (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: _group.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 100, 8, 8),
                child: ListView.builder(
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[widget.index ?? 0];
                      return Container(
                        height: 300,
                        color: Colors.white,
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: documentSnapshot['imageurl'] !=
                                    null
                                ? NetworkImage(documentSnapshot['imageurl'])
                                : NetworkImage(
                                        "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png")
                                    as ImageProvider,
                          ),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(documentSnapshot['name'],
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 10),
                              Text(
                                  "Total Amount : ₹${documentSnapshot['total']}",
                                  style: const TextStyle(fontSize: 20)),
                              for (int i = 0;
                                  i < documentSnapshot['no of shares'];
                                  i++)
                                Text(
                                  "Share ${i + 1}: ₹${documentSnapshot["share$i"]}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                            ],
                          ),
                          trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  ( widget.type == "sa" ||  widget.type == "ad")?  IconButton(
                                      onPressed: () {
                                        setState(() {
                                          no_of_share =
                                              documentSnapshot['no of shares'];
                                        });
                                        _showEditDialog(documentSnapshot);
                                      },
                                      icon: const Icon(Icons.edit)): SizedBox(),
                                  widget.type == "sa"
                                      ? IconButton(
                                          onPressed: () {
                                            _delete(documentSnapshot.id);
                                          },
                                          icon: const Icon(Icons.delete))
                                      : SizedBox(),
                                ],
                              )),
                        ),
                      );
                    }),
              );
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
