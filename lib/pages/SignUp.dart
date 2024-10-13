import 'package:flutter/material.dart';
import 'package:flutter_midterm_project/Service/Auth_Service.dart';
import 'package:flutter_midterm_project/pages/Home.dart';
import 'package:flutter_midterm_project/pages/PhoneAuth.dart';
import 'package:flutter_midterm_project/pages/SignIn.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  firebase_auth.FirebaseAuth  firebaseAuth = firebase_auth.FirebaseAuth.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool circular = false;
  AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ButtonItem("assets/google.svg", "Continue with Google", 25, ()async {
                await authService.googleSignIn(context);
              } ),
              SizedBox(
                height: 15,
              ),
              ButtonItem("assets/phone.svg", "Continue with Phone", 30, (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (builder) => Phoneauth()),
                  );
              }),
              SizedBox(
                height: 15,
              ),
              Text(
                "Or",
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(
                height: 15,
              ),
              textItem("Email...",_emailController, false),
              SizedBox(
                height: 15,
              ),
              textItem("Password...",_passwordController, true),
              SizedBox(
                height: 30,
              ),
              colorButton(),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("If you already have an Account? ",style: TextStyle(fontSize: 18),),
                  InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context, 
                        MaterialPageRoute(builder: (builder) => SignIn()),
                        (route) => false,
                        );
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold),
                        ),
                        ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget colorButton() 
  {
    return InkWell(
      onTap: () async {
        setState(() {
          circular = true;
        });
        try
        {
          firebase_auth.UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text, 
          password: _passwordController.text,
        );
        print(userCredential.user?.email);
        setState(() {
          circular = false;
        });
        Navigator.pushAndRemoveUntil(
          context, 
          MaterialPageRoute(builder: (builder) => Home()),
          (route) => false
        );
        }catch(e){
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          setState(() {
            circular = false;
          });
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 90,
        height: 60,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [
            Color(0xfffd746c), 
            Color(0xffff9068), 
            Color(0xfffd746c)]
            ),
        ),
        child: Center(
          child: circular 
          ? CircularProgressIndicator() 
          : Text("Sign Up", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),)),
      ),
    );
  }

  Widget ButtonItem(String imagepath, String buttonName, double size, VoidCallback onTap) {
    return InkWell(
      onTap: onTap ,
      child: Container(
        width: MediaQuery.of(context).size.width - 60,
        height: 60,
        child: Card(
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                imagepath,
                height: size,
                width: size,
              ),
              SizedBox(width: 15),
              Text(
                buttonName,
                style: TextStyle(fontSize: 17),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget textItem(String labelText, TextEditingController controller, bool obscureText) {
    return Container(
      width: MediaQuery.of(context).size.width - 70,
      height: 55,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 17),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 1.5,
              color: Colors.amber,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              width: 1,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
