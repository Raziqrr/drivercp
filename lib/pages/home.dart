/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-05 23:28:25
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-10 00:03:22
/// @FilePath: lib/pages/home.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivercp/pages/add.dart';
import 'package:drivercp/widgets/CustomRideOverview.dart';
import 'package:drivercp/widgets/PrimaryButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.uid});
  final String uid;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic> userData = {};
  List<String> categories = [];

  final Stream<QuerySnapshot> _rideStream =
      FirebaseFirestore.instance.collection('Rides').snapshots();

  void GetUser() async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("Users").doc(widget.uid);
    docRef.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        print(data);
        setState(() {
          userData = data;
        });
        // ...
      },
      onError: (e) => print("Error getting document: $e"),
    );
  }

  void Logout() async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.remove("uid");
    Navigator.pop(context);
  }

  @override
  void initState() {
    // TODO: implement initState
    GetUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (userData == {}) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                  child: Primarybutton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return AddPage(
                            uid: widget.uid,
                            userData: userData,
                          );
                        }));
                      },
                      text: "Create new ride")),
            ],
          ),
        ),
        appBar: AppBar(
          actions: [
            TextButton(
                onPressed: () {
                  Logout();
                },
                child: Text("log out"))
          ],
          title: Text("Kongsi Kereta"),
          leading: Padding(
            padding: const EdgeInsets.all(15.0),
            child: userData["userImage"] != null
                ? Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(userData["userImage"]))),
                  )
                : CircularProgressIndicator(),
          ),
        ),
        body: Padding(
          padding:
              const EdgeInsets.only(top: 20, right: 15, left: 15, bottom: 60),
          child: Column(
            children: [
              Row(
                children: [
                  RawChip(
                      selectedColor: CupertinoColors.systemGreen,
                      selected: categories.contains("completed"),
                      onPressed: () {
                        if (categories.contains("completed")) {
                          categories.remove("completed");
                          setState(() {});
                        } else {
                          categories.add("completed");
                          setState(() {});
                        }
                      },
                      label: Text("Completed")),
                  SizedBox(
                    width: 10,
                  ),
                  RawChip(
                      selectedColor: CupertinoColors.systemYellow,
                      selected: categories.contains("pending"),
                      onPressed: () {
                        if (categories.contains("pending")) {
                          categories.remove("pending");
                          setState(() {});
                        } else {
                          categories.add("pending");
                          setState(() {});
                        }
                      },
                      label: Text("Pending")),
                ],
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _rideStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: const Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: const CircularProgressIndicator());
                  }
                  final rideList = snapshot.data!.docs.where((doc) {
                    print(doc);
                    return (doc["driverId"] == widget.uid &&
                        categories.contains(doc["status"]));
                  }).toList();

                  if (rideList.isEmpty) {
                    return Center(child: Text("You don't have any rides."));
                  }

                  return Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: rideList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ride =
                            rideList[index].data() as Map<String, dynamic>;
                        print(ride);
                        return CustomRideOverview(
                            rideId: rideList[index].id,
                            driverId: widget.uid,
                            rideDetails: ride);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
    ;
  }
}
