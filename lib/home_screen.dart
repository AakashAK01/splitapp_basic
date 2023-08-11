import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:splitwise_basic/billsplitscreen.dart';

import 'group_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference _group =
      FirebaseFirestore.instance.collection('group');
  TextEditingController groudnameController = TextEditingController();
  String? name;

  Future<void> _delete(String groupID) async {
    await _group.doc(groupID).delete();
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
          onPressed: () {
            _create();
          },
        ),
      ),
    );
  }
}
