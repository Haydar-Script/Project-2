import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'show_players.dart';

// domain of your server
const String _baseURL = 'csci410haydar.000webhostapp.com';

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  // creates a unique key to be used by the form
  // this key is necessary for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _controllerID = TextEditingController();
  TextEditingController _controllerName = TextEditingController();
  TextEditingController _controllerBalance = TextEditingController();
  // the below variable is used to display the progress bar when retrieving data
  bool _loading = false;

  @override
  void dispose() {
    _controllerID.dispose();
    _controllerName.dispose();
    _controllerBalance.dispose();
    super.dispose();
  }

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Player'),
          centerTitle: true,
          backgroundColor: Colors.red,
          // the below line disables the back button on the AppBar
          automaticallyImplyLeading: false,
        ),
        body: Center(
            child: Form(
          key:
              _formKey, // key to uniquely identify the form when performing validation
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _controllerID,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter ID',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter player id';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _controllerName,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Player Name',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter player name';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _controllerBalance,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter Balance',
                    ),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter balance';
                      }
                      return null;
                    },
                  )),
              const SizedBox(height: 10),
              ElevatedButton(
                // we need to prevent the user from sending another request, while current
                // request is being processed
                onPressed: _loading
                    ? null
                    : () {
                        // disable button while loading
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _loading = true;
                          });
                          saveCustomer(
                              update,
                              int.parse(_controllerID.text),
                              _controllerName.text,
                              double.parse(_controllerBalance.text));
                        }
                      },
                child: const Text('Add Player'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ShowPlayers()));
                },
                child: const Text('Show Players'),
              ),
              const SizedBox(height: 10),
              Visibility(
                  visible: _loading, child: const CircularProgressIndicator())
            ],
          ),
        )));
  }
}

void saveCustomer(
    Function(String text) update, int cid, String name, double balance) async {
  try {
    // we need to first retrieve and decrypt the key
    // send a JSON object using http post
    final response = await http
        .post(Uri.parse('$_baseURL/saveCustomer.php'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            }, // convert the cid, name and key to a JSON object
            body: convert.jsonEncode(<String, String>{
              'cid': '$cid',
              'name': name,
              'balance': '$balance',
              'key': 'your_key'
            }))
        .timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      // if successful, call the update function
      update(response.body);
    }
  } catch (e) {
    update(e.toString());
  }
}
