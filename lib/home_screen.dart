import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:splitwise_basic/Utils/utils.dart';
import 'package:splitwise_basic/authenication_screen.dart';
import 'package:splitwise_basic/billsplitscreen.dart';
import 'package:splitwise_basic/main.dart';

import 'package:splitwise_basic/webviewscreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'Utils/speech_to_text.dart';
import 'group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _group =
      FirebaseFirestore.instance.collection('group');
  late WebViewController webViewController;
  TextEditingController groudnameController = TextEditingController();
  final auth = FirebaseAuth.instance;
  String? name;
  final _razorpay = Razorpay();
  double? amount;

  @override
  void initState() {
    super.initState();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key': 'rzp_test_TVuRoan6e8ILQX',
      'amount': 5000,
      'name': 'Test 123',
      'description': 'Payment',
      'prefill': {'contact': '8888888888', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: response.message.toString(),
    );
    print(response.message.toString());
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName.toString());
  }

  Future<void> _delete(String groupID) async {
    await _group.doc(groupID).delete();
  }

  void _paymentsheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Enter Amount',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Amount'),
                onChanged: (v) {
                  amount = double.tryParse(v);
                  amount = (amount ?? 1) * 100;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  openCheckout();
                  Navigator.pop(context); // Close the bottom sheet
                },
                child: Text('Pay'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _update(DocumentSnapshot? documentSnapshot) async {
    groudnameController.text = documentSnapshot?['name'] ?? '';
    name = documentSnapshot?['name'] ?? '';
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: "Group Name",
                  ),
                  onChanged: (v) {
                    name = v;
                  },
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                    onPressed: () async {
                      if (name != null) {
                        await _group
                            .doc(documentSnapshot!.id)
                            .update({"name": name});
                        name = "";
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Update")),
              ],
            ),
          );
        });
  }

  Future<void> _create([DocumentSnapshot? documentSnapshot]) async {
    await showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Group Name",
                  ),
                  onChanged: (v) {
                    setState(() {
                      name = v;
                    });
                  },
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                    onPressed: () async {
                      if (name != null) {
                        await _group.add({"name": name});
                        name = "";
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Add")),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text('Home Screen'),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.login_outlined),
                onPressed: () {
                  auth.signOut().then((value) async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Authentication(),
                      ),
                    );
                    flutterLocalNotificationsPlugin.show(
                        0,
                        "Logged Out",
                        "You have been successfully logged out.",
                        NotificationDetails(
                            android: AndroidNotificationDetails(
                                channel.id, channel.name,
                                channelDescription: channel.description,
                                color: Colors.white,
                                playSound: true,
                                importance: Importance.high,
                                icon: '@mipmap/ic_launcher')));
                    String? fcmKey =
                        await FirebaseMessaging.instance.getToken();

                    print(fcmKey);
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(error.toString());
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.web),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.currency_rupee),
                onPressed: () {
                  _paymentsheet();
                },
              ),
              IconButton(
                icon: Icon(Icons.mic),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SpeechToTextScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder(
          stream: _group.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot =
                        streamSnapshot.data!.docs[index];

                    return InkWell(
                      onTap: () async {
                        final fetchedDocumentSnapshot = await _group
                            .doc(documentSnapshot.id)
                            .get(); // Fetch the document data

                        if (fetchedDocumentSnapshot.exists) {
                          final data = fetchedDocumentSnapshot.data()
                              as Map<String, dynamic>;

                          if (data.containsKey('share1') &&
                              data['share1'] != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupScreen(index: index),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BillSplitScreen(
                                    id: fetchedDocumentSnapshot.id,
                                    index: index),
                              ),
                            );
                          }
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          // leading: CircleAvatar(
                          //     backgroundImage:
                          //         NetworkImage(documentSnapshot['imageurl'])),
                          title: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(documentSnapshot['name'],
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                            ],
                          ),
                          trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _update(documentSnapshot);
                                      },
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () {
                                        _delete(documentSnapshot.id);
                                      },
                                      icon: const Icon(Icons.delete)),
                                ],
                              )),
                        ),
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
      floatingActionButton: Container(
        height: 50,
        width: 120,
        child: FloatingActionButton(
          backgroundColor: Colors.black.withOpacity(0.6),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: const Text("Create Group"),
          onPressed: () async {
            _create();
          },
        ),
      ),
    );
  }
}
