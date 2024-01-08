import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'show_players.dart';

// domain of the server
const String _baseURL = 'https://esterwebt.000webhostapp.com/';

class AddPlayer extends StatefulWidget {
  const AddPlayer({super.key});

  @override
  State<AddPlayer> createState() => _AddPlayerState();
}

class _AddPlayerState extends State<AddPlayer> {
  // text editing controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coinsController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  bool _loading = false;

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
          // disable back button on the AppBar
          automaticallyImplyLeading: false,
          // make the app bar smaller
          toolbarHeight: 30,
          foregroundColor: Colors.deepPurple,
        ),
        body: Center(
            child: Form(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Player name...',
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _coinsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Number of coins...',
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _rankController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Player rank...',
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: _hoursController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Hours played...',
                    ),
                  )),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    // prevent sending another request while current request is being processed
                    onPressed: _loading
                        ? null
                        : () {
                            // disable button while loading
                            setState(() {
                              _loading = true;
                            });
                            try {
                              savePlayer(
                                  update,
                                  _nameController.text,
                                  double.parse(_coinsController.text),
                                  int.parse(_rankController.text),
                                  int.parse(_hoursController.text));
                            } catch (e) {
                              update("Invalid data entered");
                            }
                          },
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) => const ShowPlayers()));
                    },
                    child: const Icon(Icons.group),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Visibility(visible: _loading, child: const CircularProgressIndicator())
            ],
          ),
        )));
  }
}

void savePlayer(Function(String text) update, String playerName, double coins, int rank,
    int hoursPlayed) async {
  if (playerName.isEmpty) {
    update("Name can't be empty");
    return;
  }
  if (coins.isNegative || coins.isNaN) {
    update("Number of coins must be a positive number");
    return;
  }
  if (rank.isNaN || rank.isNegative) {
    update("Rank must be a positive integer");
    return;
  }
  if (hoursPlayed.isNaN || hoursPlayed.isNegative) {
    update("Number of hours played must be a positive integer");
    return;
  }

  try {
    final response = await http
        .post(Uri.parse('$_baseURL/addPlayer.php'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: convert.jsonEncode(<String, String>{
              'name': playerName,
              'coins': '$coins',
              'rank': '$rank',
              'hoursPlayed': '$hoursPlayed'
            }))
        .timeout(const Duration(seconds: 30));
    update(response.body);
  } catch (e) {
    update(e.toString());
  }
}
