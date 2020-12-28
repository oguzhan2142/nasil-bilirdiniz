import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:kpss_tercih/login_page/authentication_service.dart';
import 'package:kpss_tercih/database.dart';
import 'package:provider/provider.dart';

class Login extends StatelessWidget {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
      ),
      backgroundColor: Colors.teal,
      resizeToAvoidBottomInset: false,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome',
                            style: TextStyle(
                              color: Colors.white60,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Sing In",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      )),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(60, 40, 60, 0),
                    child: Column(
                      children: [
                        TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            print('parola unuttum');
                          },
                          child: Text(
                            'Forget Password?',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.65,
                              color: Colors.teal,
                              onPressed: () {
                                context
                                    .read<AuthenticationService>()
                                    .singIn(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    )
                                    .then((success) => {
                                          
                                        });
                              },
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                'Sing In',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    letterSpacing: 1.1),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(children: <Widget>[
                          Expanded(child: Divider(thickness: 1.2)),
                          SizedBox(width: 10),
                          Text("OR",
                              style: TextStyle(
                                  color: Colors.grey,
                                  letterSpacing: 1.2,
                                  fontSize: 15)),
                          SizedBox(width: 10),
                          Expanded(child: Divider(thickness: 1.2)),
                        ]),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('res/google.png', width: 32),
                            SizedBox(width: 40),
                            Image.asset('res/facebook.png', width: 32),
                          ],
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            print('Sing up');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/singup');
                                  },
                                  child: Text(
                                    'SingUp',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
