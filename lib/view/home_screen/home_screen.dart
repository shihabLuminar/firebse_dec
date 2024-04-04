// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drawer_firebse_dec/view/login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phController = TextEditingController();
  CollectionReference collecitonReference =
      FirebaseFirestore.instance.collection("students");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                    (route) => false);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: phController,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                collecitonReference.add(
                    {"name": nameController.text, "ph": phController.text});
              },
              child: Text("Add"),
            ),
            SizedBox(height: 20),
            Expanded(
                child: StreamBuilder(
              stream: collecitonReference.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("error");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //
                        final DocumentSnapshot employeeSnap =
                            snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(employeeSnap["name"]),
                          subtitle: Text(employeeSnap["ph"]),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    collecitonReference
                                        .doc(employeeSnap.id)
                                        .set({
                                      "name": nameController.text,
                                      "ph": phController.text
                                    });
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                  onPressed: () {
                                    collecitonReference
                                        .doc(employeeSnap.id)
                                        .delete();
                                  },
                                  icon: Icon(Icons.delete))
                            ],
                          ),
                        );
                      });
                }
              },
            ))
          ],
        ),
      ),
    );
  }
}
