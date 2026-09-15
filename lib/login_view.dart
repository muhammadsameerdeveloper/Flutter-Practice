import 'package:flutter/material.dart';
import 'package:practiceapp/periodictable.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  dynamic login(context) {
    if (emailController.text == "Admin@gmail.com" &&
        passwordController.text == "123456") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PeriodicTable()),
      );
    } else {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: "Password",
              border: OutlineInputBorder(),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              login(context);
            },
            child: Text("Login"),
          ),
        ],
      ),
    );
  }
}
