// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drawer_firebse_dec/view/login_screen/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? pickedImage;
  TextEditingController nameController = TextEditingController();
  TextEditingController phController = TextEditingController();
  CollectionReference collecitonReference =
      FirebaseFirestore.instance.collection("students");
  var url;
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
            InkWell(
              onTap: () async {
// write code to pick image using camera
                pickedImage =
                    await ImagePicker().pickImage(source: ImageSource.camera);

                // to upload image to firebase storage if picked image is not null
                if (pickedImage != null) {
                  final uniqueName =
                      DateTime.timestamp().microsecondsSinceEpoch.toString();
                  //reference to the root storage
                  final rootReference = FirebaseStorage.instance.ref();

                  // funciotn to create a folder named employeeImages
                  final imagesRef = rootReference.child("employeeImages");
                  // name in which the image will be stored in the folder
                  final uploadRef = imagesRef.child("$uniqueName");
                  // upload image
                  await uploadRef.putFile(File(pickedImage!.path));
                  //get download url
                  url = await uploadRef.getDownloadURL();
                  setState(() {});
                  if (url != null) {
                    log("image uploaded successfully");
                    log(url.toString());
                  } else {
                    log("failed to upload image");
                  }
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.black,
                radius: 70,
                backgroundImage: url != null ? NetworkImage(url) : null,
              ),
            ),
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
                collecitonReference.add({
                  "name": nameController.text,
                  "ph": phController.text,
                  "image": url
                });
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
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              employeeSnap["image"],
                            ),
                            radius: 40,
                          ),
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
