/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-05 22:46:31
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-07 17:40:10
/// @FilePath: lib/pages/register.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drivercp/widgets/CustomTextField.dart';
import 'package:drivercp/widgets/SecondaryButton.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/PrimaryButton.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int pageIndex = 0;

  TextEditingController icController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  TextEditingController carBrandController = TextEditingController();
  TextEditingController carModelController = TextEditingController();
  TextEditingController sittingCapacityController = TextEditingController();
  List<String> carSpecialFeatures = [];
  List<TextEditingController> carSpecialFeaturesController = [];

  Uint8List? carImage;
  Uint8List? userImage;

  String gender = "";

  String icErrorText = "";
  String passwordErrorText = "";
  String nameErrorText = "";
  String emailErrorText = "";
  String phoneErrorText = "";
  String carBrandErrorText = "";
  String carModelErrorText = "";
  String sittingCapacityErrorText = "";
  String carImageErrorText = "";
  String userImageErrorText = "";
  String addressErrorText = "";

  bool icIsValid = false;
  bool passwordIsValid = false;
  bool nameIsValid = false;
  bool emailIsValid = false;
  bool phoneIsValid = false;
  bool carBrandIsValid = false;
  bool carModelIsValid = false;
  bool sittingCapacityIsValid = false;
  bool carImageIsValid = false;
  bool userImageIsValid = false;
  bool genderIsValid = false;
  bool addrressIsValid = false;

  bool hidePassword = true;

  String? userImageName;

  void CheckIc(String ic, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${ic}@driver.cc", password: password);
      String uid = credential.user!.uid;
      Navigator.pop(context);
      print('User with IC Number ${ic} already exists');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        print('No user found for that email.');
        setState(() {
          pageIndex += 1;
        });
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        print('User with IC Number ${ic} already exists');
      }
    }
  }

  void PickUserImage(ImageSource source, BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      final imageData = await File(pickedImage.path).readAsBytes();
      if (imageData != null) {
        userImage = imageData;
        userImageName = pickedImage.name;
        userImageIsValid = true;
        setState(() {});
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        print("Error uploading picture");
      }
    } else {
      Navigator.pop(context);
      print("Error uploading picture");
    }
  }

  void PickCarImage(ImageSource source, BuildContext context) async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(source: source);
    if (pickedImage != null) {
      final imageData = await File(pickedImage.path).readAsBytes();
      if (imageData != null) {
        carImage = imageData;
        carImageIsValid = true;
        setState(() {});
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        print("Error uploading picture");
      }
    } else {
      Navigator.pop(context);
      print("Error uploading picture");
    }
  }

  void Register(
      String ic,
      String password,
      String name,
      String email,
      String phone,
      String gender,
      Uint8List userImage,
      Uint8List carImage,
      String carBrand,
      String carModel,
      int carCapacity,
      List<String> carSpecialFeatures,
      String address,
      BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: CircularProgressIndicator());
      },
    );
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: "${ic}@driver.cc",
        password: password,
      );

      final userImageRef = FirebaseStorage.instance.ref(
          "driver/images/${credential.user!.uid}/profile/${DateTime.now()}.jpg");
      await userImageRef.putData(userImage);

      final userImageUrl = await userImageRef.getDownloadURL();

      final carImageRef = FirebaseStorage.instance.ref(
          "driver/images/${credential.user!.uid}/car/${DateTime.now()}.jpg");
      await carImageRef.putData(carImage);

      final carImageUrl = await carImageRef.getDownloadURL();

      final data = {
        "ic": ic,
        "name": name,
        "email": email,
        "phone": phone,
        "gender": gender,
        "carBrand": carBrand,
        "carModel": carModel,
        "carCapacity": carCapacity,
        "carSpecialFeatures": carSpecialFeatures,
        "avgRating": 0,
        "ratingCount": 0,
        "userImage": userImageUrl,
        "carImage": carImageUrl,
        "role": "driver"
      };

      final db = FirebaseFirestore.instance;
      db.collection("Users").doc(credential.user!.uid).set(data);

      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Registration Successful")));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        print('The account already exists for that email.');
      }
    } catch (e) {
      Navigator.pop(context);
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: [
          SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: MediaQuery.sizeOf(context).width * 40 / 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Register"),
                        Text("Create a new driver account"),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Customtextfield(
                    controller: icController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12)
                    ],
                    keyboardType: TextInputType.number,
                    hintText: "IC Number",
                    errorText: icErrorText,
                    onChanged: (value) {
                      if (value.length < 12) {
                        icErrorText = "Invalid IC Number";
                        icIsValid = false;
                      } else {
                        icErrorText = "";
                        icIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 20,
                ),
                Customtextfield(
                    controller: passwordController,
                    obscureText: hidePassword,
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                        icon: hidePassword == true
                            ? Icon(
                                CupertinoIcons.eye_slash_fill,
                                color: Colors.grey,
                              )
                            : Icon(
                                CupertinoIcons.eye_fill,
                                color: Colors.grey,
                              )),
                    inputFormatters: [],
                    hintText: "Password",
                    errorText: passwordErrorText,
                    onChanged: (value) {
                      if (value.length < 6) {
                        passwordErrorText =
                            "Password length must be more than 6";
                        passwordIsValid = false;
                      } else {
                        passwordErrorText = "";
                        passwordIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Primarybutton(
                      text: "Continue",
                      onPressed: (icIsValid == true && passwordIsValid == true)
                          ? () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                },
                              );
                              CheckIc(icController.text,
                                  passwordController.text, context);
                            }
                          : null,
                    )),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Divider(
                      thickness: 2,
                      color: Colors.grey,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 25,
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: Text("Or"),
                      ),
                    )
                  ],
                ),
                Center(
                    child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Login with an existing account")))
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                Center(child: Text("Complete Registration")),
                SizedBox(
                  height: 40,
                ),
                Customtextfield(
                    controller: nameController,
                    inputFormatters: [],
                    hintText: "Name",
                    errorText: nameErrorText,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        nameErrorText = "Name cannot be empty";
                        nameIsValid = false;
                      } else {
                        nameErrorText = "";
                        nameIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 20,
                ),
                Customtextfield(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    inputFormatters: [],
                    hintText: "Email",
                    errorText: emailErrorText,
                    onChanged: (value) {
                      bool isValid = EmailValidator.validate(value);

                      if (isValid == false) {
                        emailErrorText = "Invalid email";
                      } else {
                        emailErrorText = "";
                      }
                      emailIsValid = isValid;
                      setState(() {});
                    }),
                SizedBox(
                  height: 20,
                ),
                Customtextfield(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11)
                    ],
                    hintText: "Phone Number",
                    errorText: phoneErrorText,
                    onChanged: (value) {
                      if (value.length < 10) {
                        phoneErrorText = "Invalid phone number";
                        phoneIsValid = false;
                      } else {
                        phoneErrorText = "";
                        phoneIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 20,
                ),
                Customtextfield(
                    maxLines: 3,
                    controller: addressController,
                    inputFormatters: [],
                    hintText: "Address",
                    errorText: addressErrorText,
                    onChanged: (value) {
                      if (value.isEmpty) {
                        addressErrorText = "Address cannot be empty";
                        addrressIsValid = false;
                      } else {
                        addressErrorText = "";
                        addrressIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text("Gender"),
                    SizedBox(
                      width: 20,
                    ),
                    if (gender == "") Text("( Please select a gender )")
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                RadioListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text("Male"),
                    value: "Male",
                    groupValue: gender,
                    onChanged: (value) {
                      gender = value!;
                      if (value.isNotEmpty) {
                        genderIsValid = true;
                      }
                      setState(() {});
                    }),
                RadioListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text("Female"),
                    value: "Female",
                    groupValue: gender,
                    onChanged: (value) {
                      gender = value!;
                      if (value.isNotEmpty) {
                        genderIsValid = true;
                      }
                      setState(() {});
                    }),
                RadioListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text("Other"),
                    value: "Other",
                    groupValue: gender,
                    onChanged: (value) {
                      gender = value!;
                      if (value.isNotEmpty) {
                        genderIsValid = true;
                      }
                      setState(() {});
                    }),
                SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Text("Profile Picture"),
                    SizedBox(
                      width: 20,
                    ),
                    if (userImage == null)
                      Text("( Please select a profile picture )")
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                if (userImage == null)
                  Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Center(
                                          child: Text("Choose upload method")),
                                      actions: [
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        PickUserImage(
                                                            ImageSource.camera,
                                                            context);
                                                      },
                                                      child: Text("Camera")),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                      onPressed: () {
                                                        PickUserImage(
                                                            ImageSource.gallery,
                                                            context);
                                                      },
                                                      child: Text("Gallery")),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Text("Upload"))),
                    ],
                  )
                else
                  Card(
                    child: ListTile(
                      trailing: IconButton(
                          onPressed: () {
                            userImage = null;
                            userImageName = null;
                            setState(() {});
                          },
                          icon: Icon(
                            CupertinoIcons.xmark_circle,
                            color: Colors.red,
                          )),
                      title: Text(userImageName!),
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(userImage!)),
                    ),
                  ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SecondaryButton(
                        onPressed: () {
                          setState(() {
                            pageIndex -= 1;
                          });
                        },
                        text: "Back"),
                    Primarybutton(
                        onPressed: (nameIsValid == true &&
                                emailIsValid == true &&
                                phoneIsValid == true &&
                                genderIsValid == true &&
                                userImageIsValid == true &&
                                addrressIsValid == true)
                            ? () {
                                setState(() {
                                  pageIndex += 1;
                                });
                              }
                            : null,
                        text: "Next")
                  ],
                )
              ],
            ),
          ),
          SingleChildScrollView(
              child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Center(child: Text("Complete Registration")),
              SizedBox(
                height: 40,
              ),
              Customtextfield(
                  controller: carBrandController,
                  inputFormatters: [],
                  hintText: "Car Brand",
                  errorText: carBrandErrorText,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      carBrandErrorText = "Car brand cannot be empty";
                      carBrandIsValid = false;
                    } else {
                      carBrandErrorText = "";
                      carBrandIsValid = true;
                    }
                    setState(() {});
                  }),
              SizedBox(
                height: 20,
              ),
              Customtextfield(
                  controller: carModelController,
                  inputFormatters: [],
                  hintText: "Car Model",
                  errorText: carModelErrorText,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      carModelErrorText = "Car Model cannot be empty";
                      carModelIsValid = false;
                    } else {
                      carModelErrorText = "";
                      carModelIsValid = true;
                    }
                    setState(() {});
                  }),
              SizedBox(
                height: 20,
              ),
              Customtextfield(
                  controller: sittingCapacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  hintText: "Car Capacity",
                  errorText: sittingCapacityErrorText,
                  onChanged: (value) {
                    if (value.isEmpty) {
                      sittingCapacityErrorText = "Car capacity cannot be empty";
                      sittingCapacityIsValid = false;
                    } else if (value == "0") {
                      sittingCapacityErrorText = "Car capacity cannot be 0";
                      sittingCapacityIsValid = false;
                    } else if (value[0] == "0") {
                      sittingCapacityErrorText =
                          "Car capacity cannot start with 0";
                      sittingCapacityIsValid = false;
                    } else {
                      sittingCapacityErrorText = "";
                      sittingCapacityIsValid = true;
                    }
                    setState(() {});
                  }),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Car Special Features"),
                  IconButton(
                      onPressed: () {
                        carSpecialFeatures.add("");
                        carSpecialFeaturesController
                            .add(TextEditingController());
                        setState(() {});
                        print(carSpecialFeatures);
                      },
                      icon: Icon(
                        CupertinoIcons.add,
                        color: CupertinoColors.systemGreen,
                      ))
                ],
              ),
              ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: carSpecialFeatures.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      title: TextField(
                        onChanged: (value) {
                          carSpecialFeatures[index] = value;
                          print(carSpecialFeatures);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            hintText: "Enter Feature"),
                        controller: carSpecialFeaturesController[index],
                      ),
                      leading: IconButton(
                          onPressed: () {
                            carSpecialFeatures.removeAt(index);
                            carSpecialFeaturesController.removeAt(index);
                            setState(() {});
                          },
                          icon: Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.red,
                          )),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                children: [
                  Text("Car Picture"),
                  SizedBox(
                    width: 20,
                  ),
                  if (carImage == null)
                    Text("( Please select a picture of the car )")
                ],
              ),
              SizedBox(
                height: 20,
              ),
              if (carImage == null)
                Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Center(
                                        child: Text("Choose upload method")),
                                    actions: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      PickCarImage(
                                                          ImageSource.camera,
                                                          context);
                                                    },
                                                    child: Text("Camera")),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      PickCarImage(
                                                          ImageSource.gallery,
                                                          context);
                                                    },
                                                    child: Text("Gallery")),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text("Upload"))),
                  ],
                )
              else
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey, width: 3)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(userImage!)),
                      ),
                      IconButton(
                          onPressed: () {
                            carImage = null;
                            setState(() {});
                          },
                          icon: Icon(
                            CupertinoIcons.xmark_circle,
                            color: Colors.red,
                          ))
                    ],
                  ),
                ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecondaryButton(
                      onPressed: () {
                        setState(() {
                          pageIndex -= 1;
                        });
                      },
                      text: "Back"),
                  Primarybutton(
                      onPressed: (carBrandIsValid == true &&
                              carModelIsValid == true &&
                              sittingCapacityIsValid == true &&
                              carImageIsValid == true)
                          ? () {
                              Register(
                                  icController.text,
                                  passwordController.text,
                                  nameController.text,
                                  emailController.text,
                                  phoneController.text,
                                  gender,
                                  userImage!,
                                  carImage!,
                                  carBrandController.text,
                                  carModelController.text,
                                  int.parse(sittingCapacityController.text),
                                  carSpecialFeatures,
                                  addressController.text,
                                  context);
                            }
                          : null,
                      text: "Register")
                ],
              )
            ],
          ))
        ][pageIndex],
      ),
    );
  }
}
