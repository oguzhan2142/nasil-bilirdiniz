import 'package:kpss_tercih/firebase/database.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'authentication_service.dart';

class SingUp extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        elevation: 0,
        shadowColor: Colors.amber,
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
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
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Sing Up",
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: Colors.grey[850],
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
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              labelStyle: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'E-mail',
                              labelStyle: TextStyle(
                                color: Colors.grey[850],
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[850],
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.65,
                              color: Colors.amber,
                              onPressed: () {
                                context
                                    .read<AuthenticationService>()
                                    .singUp(
                                        email: emailController.text.trim(),
                                        password:
                                            passwordController.text.trim())
                                    .then((isSuccess) {
                                  if (isSuccess) {
                                    addUserToDb(nameController.text.trim());
                                    Navigator.pop(context);
                                  } else {
                                    print('basarisiz sing up');
                                  }
                                });
                              },
                              padding: EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                'Sing Up',
                                style: TextStyle(
                                    color: Colors.grey[850],
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
