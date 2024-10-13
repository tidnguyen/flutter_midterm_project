import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class Phoneauth extends StatefulWidget {
  const Phoneauth({super.key});

  @override
  State<Phoneauth> createState() => _PhoneauthState();
}

class _PhoneauthState extends State<Phoneauth> {
  int start = 30;
  bool wait = false;
  String buttonName = "Send";
  TextEditingController phoneController = TextEditingController();
  AuthService authService = AuthService();
  String verificationIdFinal = "";
  String smsCode = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Sign up",
          style: TextStyle(color: Colors.black, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              textField(),
              SizedBox(
                height: 40,
              ),
              Container(
                  width: MediaQuery.of(context).size.width - 30,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey),
                      ),
                      Text(
                        " Enter 5 Digit OTP ",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey),
                      ),
                    ],
                  )),
              SizedBox(
                height: 40,
              ),
              otpField(),
              SizedBox(
                height: 40,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Send OTP again in",
                      style:
                          TextStyle(fontSize: 20, color: Colors.orangeAccent),
                    ),
                    TextSpan(
                      text: " 00:$start ",
                      style: TextStyle(fontSize: 20, color: Colors.red),
                    ),
                    TextSpan(
                      text: "sec",
                      style:
                          TextStyle(fontSize: 20, color: Colors.orangeAccent),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 150,
              ),
              InkWell(
                onTap: () {
                  authService.signInwithPhoneNumber(verificationIdFinal, smsCode, context);
                },
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width - 60,
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      "Let's Go",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget otpField() {
    return OtpTextField(
      numberOfFields: 5,
      borderColor: Color(0xFF512DA8),
      borderWidth: 4.0,
      fieldWidth: 60,
      //set to true to show as box or false to show as dash
      showFieldAsBox: false,
      focusedBorderColor: Colors.black,
      borderRadius: BorderRadius.circular(15),
      textStyle: TextStyle(fontSize: 30),

      //runs when a code is typed in
      onCodeChanged: (String code) {
        //handle validation or checks here
      },
      //runs when every textfield is filled
      onSubmit: (pin) {
        print("Completed: " + pin);
        setState(() {
          smsCode = pin;
        });
      }, // end onSubmit
    );
  }

  Widget textField() {
    
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 217, 217, 217),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller:  phoneController,
        style: TextStyle(color: Colors.black, fontSize: 17),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter your phone number",
          hintStyle: TextStyle(color: Colors.black, fontSize: 19),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 19, horizontal: 8),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            child: Text(
              "(+84)",
              style: TextStyle(
                color: Colors.black,
                fontSize: 17,
              ),
            ),
          ),
          suffixIcon: InkWell(
            onTap: wait
                ? null
                : () async {
                    startTimer();
                    setState(() {
                      start = 30;
                      wait = true;
                      buttonName = "Resend";
                    });
                    await authService.verifyPhoneNumber(
                      "+84 ${phoneController.text}",context, setData
                    );
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              child: Text(
                buttonName,
                style: TextStyle(
                  color: wait ? Colors.grey : Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setData(String verificationID) {
    setState(() {
      verificationIdFinal = verificationID;
    });
    startTimer();
  }
}
