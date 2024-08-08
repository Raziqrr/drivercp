/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-07 18:28:51
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-07 23:49:42
/// @FilePath: lib/pages/add.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivercp/widgets/CustomTextField.dart';
import 'package:drivercp/widgets/PrimaryButton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:intl/intl.dart';

class AddPage extends StatefulWidget {
  AddPage({super.key, required this.uid, required this.userData});
  final String uid;
  final Map<String, dynamic> userData;

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  TextEditingController originController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController fareController = TextEditingController();

  String dateErrorText = "";
  String timeErrorText = "";
  String fareErrorText = "";

  bool isOriginLocationValid = false;
  bool isDestinationLocationValid = false;
  bool isDateValid = false;
  bool isTimeValid = false;
  bool isFareValid = false;

  @override
  void dispose() {
    // TODO: implement dispose

    destinationController.dispose();
    originController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.dispose();
  }

  void Successful(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Ride successfully created")));
  }

  void Error(dynamic e) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${e}")));
  }

  void CreateRide(String origin, String destination, String date, String time,
      String fare, BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    final db = FirebaseFirestore.instance;

    final data = <String, dynamic>{
      "driverId": widget.uid,
      "carCapacity": widget.userData["carCapacity"],
      "capacityStatus": "available",
      "passengerCount": 0,
      "status": "pending",
      "ratedBy": [],
      "passengers": [],
      "date": date,
      "time": time,
      "fare": "RM${fare}",
      "origin": origin,
      "destination": destination
    };

    db
        .collection("Rides")
        .add(data)
        .then((documentSnapshot) => Successful(context), onError: (e) {
      print("Error adding document: ${e.message}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Expanded(
                child: Primarybutton(
                    onPressed: (isDestinationLocationValid == true &&
                            isOriginLocationValid == true &&
                            isDateValid == true &&
                            isTimeValid == true &&
                            isFareValid == true)
                        ? () {
                            CreateRide(
                                originController.text,
                                destinationController.text,
                                dateController.text,
                                timeController.text,
                                fareController.text,
                                context);
                          }
                        : null,
                    text: "Create")),
          ],
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Create a ride"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            PlacesAutocomplete(
                topCardColor: Colors.white,
                hideBackButton: true,
                searchHintText: "Enter origin location",
                backButton: null,
                onReset: () {
                  originController.clear();
                  setState(() {});
                },
                onSuggestionSelected: (value) {
                  originController.text = value.description!;
                  isOriginLocationValid = true;
                  setState(() {});
                },
                searchController: originController,
                controller: originController,
                topCardMargin: EdgeInsets.zero,
                top: false,
                apiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
                mounted: mounted),
            SizedBox(
              height: 10,
            ),
            PlacesAutocomplete(
                topCardColor: Colors.white,
                hideBackButton: true,
                searchHintText: "Enter destination location",
                backButton: null,
                onReset: () {
                  destinationController.clear();
                  setState(() {});
                },
                onSuggestionSelected: (value) {
                  destinationController.text = value.description!;
                  isDestinationLocationValid = true;
                  setState(() {});
                },
                searchController: destinationController,
                controller: destinationController,
                topCardMargin: EdgeInsets.zero,
                top: false,
                apiKey: "AIzaSyAXwutVf9N_fkr49lXUdlh4HPJdEjbkeqI",
                mounted: mounted),
            SizedBox(
              height: 20,
            ),
            Customtextfield(
                onTap: () async {
                  final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2025));
                  if (date != null) {
                    final formattedDate = DateFormat.MMMd().format(date);
                    print(formattedDate);
                    dateController.text = formattedDate;
                    isDateValid = true;
                    setState(() {});
                  }
                },
                controller: dateController,
                inputFormatters: [],
                hintText: "Date",
                errorText: dateErrorText,
                onChanged: (value) {}),
            SizedBox(
              height: 15,
            ),
            Customtextfield(
                readOnly: true,
                onTap: () async {
                  final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: DateTime.now().hour,
                          minute: DateTime.now().minute));
                  if (time != null) {
                    timeController.text = "${time.format(context)}";
                    isTimeValid = true;
                    setState(() {});
                  }
                },
                controller: timeController,
                inputFormatters: [],
                hintText: "Time",
                errorText: timeErrorText,
                onChanged: (value) {}),
            SizedBox(
              height: 15,
            ),
            Customtextfield(
                keyboardType: TextInputType.number,
                controller: fareController,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                hintText: "Price",
                errorText: fareErrorText,
                onChanged: (value) {
                  if (value.isEmpty) {
                    fareErrorText = "Price cannot be empty";
                    isFareValid = false;
                  } else {
                    fareErrorText = "";
                    isFareValid = true;
                  }
                  setState(() {});
                }),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
