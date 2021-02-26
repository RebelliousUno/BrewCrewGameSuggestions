// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:brewcrew/add_game_form.dart';
import 'package:brewcrew/game.dart';
import 'package:brewcrew/game_network_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Game Suggestions', home: GameSuggestions());
  }
}

class StatefulGameSuggestions extends StatefulWidget {
  @override
  _GameSuggestionState createState() => _GameSuggestionState();
}

class GameSuggestions extends StatelessWidget {
  var gameDetails = StatefulGameSuggestions();

  @override
  Widget build(BuildContext context) {
    return gameDetails;
  }
}

class _GameSuggestionState extends State<StatefulGameSuggestions> {
  var _source = GameNetworkSource();
  Future<List<Game>> _searchResult;
  var controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchResult = _source.fetchGameSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    var searchBar = Container(
        padding: const EdgeInsets.all(32),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(8), child: Icon(Icons.search)),
            Expanded(
                child: TextField(
              controller: controller,
              onChanged: onSearchTextChanged,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), hintText: "Search for a game"),
            ))
          ],
        ));
    var futureDetails = FutureBuilder<List<Game>>(
        future: _searchResult,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.length,
                itemBuilder: (context, i) {
                  return snapshot.data[i].getCard();
                });
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return CircularProgressIndicator();
        });

    var col = Column(
      children: [searchBar, futureDetails],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Game Suggestions'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add', // used by assistive technologies
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AddGameEntryForm()))
              .then((value) => refreshSearch());
        },
      ),
      body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 800,
            child: SingleChildScrollView(child: col),
          )),
    );
  }

  onSearchTextChanged(String text) {
    doSearch(text.trim());
  }

  void refreshSearch() {
    setState(() {
      _searchResult = _source.fetchGameSuggestions(true);
    });
  }

  void doSearch(String text) {
    setState(() {
      if (text.isEmpty) {
        _searchResult = _source.fetchGameSuggestions();
      } else {
        _searchResult = _source.fetchFilteredGame(text);
      }
    });
  }
}
