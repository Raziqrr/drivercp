/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-05 21:54:10
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-06 23:32:29
/// @FilePath: lib/pages/login.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:drivercp/pages/home.dart';
import 'package:drivercp/pages/register.dart';
import 'package:drivercp/widgets/CustomTextField.dart';
import 'package:drivercp/widgets/PrimaryButton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController icController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String icErrorText = "";
  String passwordErrorText = "";

  bool isIcValid = false;
  bool isPasswordValid = false;

  bool hidePassword = true;
  bool rememberMe = false;

  Future<String> GetCredentials() async {
    final _prefs = await SharedPreferences.getInstance();
    final uid = await _prefs.getString("uid");

    if (uid != null) {
      return uid;
    } else {
      return "";
    }
  }

  void StoreCredentials(String uid) async {
    final _prefs = await SharedPreferences.getInstance();
    _prefs.setString("uid", uid);
  }

  void RememberMe() async {
    String uid = await GetCredentials();
    if (uid != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomePage(
          uid: uid,
        );
      }));
    }
  }

  void Login(String ic, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: "${ic}@driver.cc", password: password);
      String uid = credential.user!.uid;
      if (rememberMe == true) {
        StoreCredentials(uid);
      }
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) {
        return HomePage(
          uid: uid,
        );
      }));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    RememberMe();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                height: MediaQuery.sizeOf(context).width * 40 / 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Text("Login"), Text("Access your driver account")],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Customtextfield(
                keyboardType: TextInputType.number,
                controller: icController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(12),
                  FilteringTextInputFormatter.digitsOnly
                ],
                hintText: "IC Number",
                errorText: icErrorText,
                onChanged: (string) {
                  if (string.length < 12) {
                    icErrorText = "Invalid IC Number";
                    isIcValid = false;
                  } else {
                    icErrorText = "";
                    isIcValid = true;
                  }
                  setState(() {});
                },
              ),
              SizedBox(
                height: 15,
              ),
              Customtextfield(
                controller: passwordController,
                inputFormatters: [],
                obscureText: hidePassword,
                hintText: "Password",
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
                errorText: passwordErrorText,
                onChanged: (string) {
                  if (string.length < 6) {
                    passwordErrorText =
                        "Password length must be more than 6 characters";
                    isPasswordValid = false;
                  } else {
                    passwordErrorText = "";
                    isPasswordValid = true;
                  }
                  setState(() {});
                },
              ),
              SizedBox(
                height: 10,
              ),
              CheckboxListTile(
                  title: Text("Remember me"),
                  contentPadding: EdgeInsets.zero,
                  activeColor: CupertinoColors.systemGreen,
                  checkboxShape: CircleBorder(),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value!;
                    });
                  }),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: Primarybutton(
                    text: "Login",
                    onPressed: (isIcValid == true && isPasswordValid == true)
                        ? () {
                            Login(icController.text, passwordController.text);
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (BuildContext context) {
                          return RegisterPage();
                        }));
                      },
                      child: Text("Register a new account")))
            ],
          ),
        ),
      ),
    );
  }
}
