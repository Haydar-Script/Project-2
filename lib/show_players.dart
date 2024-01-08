import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// player class to store player information
class Player {
  int pid;
  String name;
  double coins;
  int rank;
  int hoursPlayed;
  Player(this.pid, this.name, this.coins, this.rank, this.hoursPlayed);
}

List<Player> _players = [];
const String _baseURL = 'esterwebt.000webhostapp.com';

class ShowPlayers extends StatefulWidget {
  const ShowPlayers({super.key});
  @override
  State<ShowPlayers> createState() => _ShowPlayersState();
}

class _ShowPlayersState extends State<ShowPlayers> {
  bool _loading = false;

  void update(String text) {
    setState(() {
      _loading = false; // show body
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void addPlayer(Player player) {
    setState(() {
      _players.add(player);
    });
  }

  void getPlayers() async {
    setState(() {
      _loading = true;
    });
    try {
      final url = Uri.https(_baseURL, 'getPlayers.php');
      final response = await http.get(url).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        // if successful call
        final jsonResponse =
            convert.jsonDecode(response.body); // create dart json object from json array
        for (var row in jsonResponse) {
          // iterate over all rows in the json array
          int pid = int.parse(row['pid']);
          String name = row['name'];
          double coins = double.parse(row['coins']);
          int rank = int.parse(row['rank']);
          int hoursPlayed = int.parse(row['hoursPlayed']);
          Player player = Player(pid, name, coins, rank, hoursPlayed);
          addPlayer(player);
        }
        update(
            "Retrieved players"); // callback update method to inform that we completed retrieving data
      }
    } catch (e) {
      update("Failed to get players"); // inform through callback that we failed to get data
    }
  }

  @override
  void initState() {
    super.initState();
    _players.clear(); // clear old players
    getPlayers(); // update players list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Available Players'),
          centerTitle: true,
        ),
        // load players
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            // if there are no players, don't load the listview
            : (_players.isEmpty
                ? const Center(
                    child: Text("no players"),
                  )
                : ListView.builder(
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      return _showPlayer(_players[index]);
                    })));
  }

  Widget _showPlayer(Player player) {
    return Card(
      child: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(Icons.account_circle),
              Text(player.name),
              const SizedBox(
                width: 20,
              ),
              Text("#${player.pid}")
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(Icons.money),
              Text('${player.coins}')
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const SizedBox(
                width: 5,
              ),
              const Icon(Icons.bar_chart),
              Text('${player.rank}'),
              const SizedBox(
                width: 20,
              ),
              const Icon(Icons.access_time),
              Text('${player.hoursPlayed}')
            ],
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
