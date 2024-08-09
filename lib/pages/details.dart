/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-08 12:26:08
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-09 23:48:54
/// @FilePath: lib/pages/details.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivercp/widgets/PrimaryButton.dart';
import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.rideId, required this.driverId});
  final String rideId;
  final String driverId;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Stream<DocumentSnapshot<Map<String, dynamic>>>? rideStream;

  @override
  void initState() {
    // TODO: implement initState
    rideStream = FirebaseFirestore.instance
        .collection('Rides')
        .doc(widget.rideId)
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: rideStream,
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(child: const Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: const CircularProgressIndicator());
        }

        final data = snapshot.data!.data();
        if (data != null) {
          return Scaffold(
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                      child: Primarybutton(
                          onPressed: data["status"] != "completed"
                              ? () {
                                  final db = FirebaseFirestore.instance;
                                  final rideRef =
                                      db.collection("Rides").doc(widget.rideId);
                                  rideRef.update({
                                    "status": "completed",
                                  });
                                }
                              : null,
                          text: "Finish")),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text('Ride Details'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text(data["date"]), Text(data["time"])],
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                  ),
                                  Container(
                                    height: 30,
                                    child: VerticalDivider(
                                      color: Colors.black,
                                      width: 2,
                                      thickness: 2,
                                    ),
                                  ),
                                  Container(
                                    height: 18,
                                    width: 18,
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("${data["origin"].split(",")[0]}"),
                                  Container(
                                    height: 30,
                                  ),
                                  Text("${data["destination"].split(",")[0]}"),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  "Passengers ( ${data["passengerCount"]}/${data["carCapacity"]} )"),
                              Text("${data["fare"]}/seat")
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (data["passengerCount"] == 0)
                            Text("No passengers at the moment"),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: data["passengers"].length,
                            itemBuilder: (BuildContext context, int index) {
                              final db = FirebaseFirestore.instance;
                              final passengerData = db
                                  .collection("Users")
                                  .doc(data["passengers"][index])
                                  .get();

                              print(data);
                              print(2);
                              if (data["passengerCount"] == 0) {
                                return Center(
                                    child: Text("No passengers at the moment"));
                              }

                              return FutureBuilder(
                                future: passengerData,
                                builder: (BuildContext context,
                                    AsyncSnapshot<
                                            DocumentSnapshot<
                                                Map<String, dynamic>>>
                                        snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                        child:
                                            const Text('Something went wrong'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                        child:
                                            const CircularProgressIndicator());
                                  }

                                  final passengerData = snapshot.data!.data();

                                  if (passengerData != null) {
                                    return ListTile(
                                      title: Text(passengerData["name"]),
                                      leading: Container(
                                        height: 30,
                                        width: 30,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                    passengerData[
                                                        "userImage"]))),
                                      ),
                                    );
                                  } else {
                                    return Center(
                                        child: Text("Error retrieving data"));
                                  }
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text("No data"));
        }
      },
    );
  }
}
