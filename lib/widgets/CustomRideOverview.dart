/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-07 17:58:42
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-08 13:01:17
/// @FilePath: lib/widgets/CustomRideOverview.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:drivercp/pages/details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomRideOverview extends StatelessWidget {
  const CustomRideOverview(
      {super.key,
      required this.rideId,
      required this.driverId,
      required this.rideDetails});
  final String rideId;
  final String driverId;
  final Map<String, dynamic> rideDetails;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return DetailPage(rideId: rideId, driverId: driverId);
        }));
      },
      child: Card(
        color: Colors.white,
        elevation: 7,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rideDetails["date"]),
                  Text(rideDetails["time"])
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Row(
                    children: [
                      Icon(Icons.person),
                      Text(
                          "${rideDetails["passengerCount"]}/${rideDetails["carCapacity"]}")
                    ],
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    height: 20,
                    child: VerticalDivider(
                      color: Colors.black,
                      width: 2,
                      thickness: 2,
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Container(
                    child: Text("${rideDetails["status"]}"),
                    padding:
                        EdgeInsets.only(left: 12, right: 12, bottom: 2, top: 2),
                    decoration: BoxDecoration(
                      color: rideDetails["status"] != "completed"
                          ? Colors.yellow
                          : CupertinoColors.systemGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  )
                ],
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
                            color: Colors.black, shape: BoxShape.circle),
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
                            color: Colors.black, shape: BoxShape.circle),
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
                      Text("${rideDetails["origin"].split(",")[0]}"),
                      Container(
                        height: 30,
                      ),
                      Text("${rideDetails["destination"].split(",")[0]}"),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [Text("${rideDetails["fare"]}/seat")],
              )
            ],
          ),
        ),
      ),
    );
  }
}
