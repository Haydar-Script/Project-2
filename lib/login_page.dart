import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter_application_2/add_player.dart';
import 'package:http/http.dart' as http;

const String _baseURL = 'csci410haydar.000webhostapp.com';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // loading state
  bool _loading = false;
  // editing controllers to get or change text in TextField widget
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // go to AddPlayer page if log in is successful
  void logIn(bool successful) {
    if (successful) {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddPlayer()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Log In failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Player Manager"),
        centerTitle: true,
      ),
      body: Center(
        child: _loading
            // hide elements when loading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Username',
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Password',
                    ),
                  ),
                  // leave some space
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        try {
                          // try to login with the username and password
                          final response = await http
                              .post(Uri.parse('$_baseURL/login.php'),
                                  headers: <String, String>{
                                    'Content-Type': 'application/json; charset=UTF-8',
                                  }, // convert the cid, name and key to a JSON object
                                  body: convert.jsonEncode(<String, String>{
                                    'username': _usernameController.text,
                                    'password': _passwordController.text,
                                  }))
                              .timeout(const Duration(seconds: 30));
                          if (response.statusCode == 200) {
                            logIn(true);
                          } else {
                            logIn(false);
                          }
                        } catch (e) {
                          logIn(false);
                        }
                        setState(() {
                          _loading = false;
                        });
                      },
                      child: const Text("Log In"))
                ],
              ),
      ),
    );
  }
}
