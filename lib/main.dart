// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:developer';

import 'package:brewcrew/game.dart';
import 'package:brewcrew/game_network_source.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(GameSuggestions());

class StatefulGameSuggestions extends StatefulWidget {
  @override
  _GameSuggestionState createState() => _GameSuggestionState();
}

class GameSuggestions extends StatelessWidget {
  Widget gameDetails = StatefulGameSuggestions();

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      child: gameDetails,
    );
    return MaterialApp(
      title: 'Game Suggestions',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Game Suggestions'),
        ),
        body: Center(
            child: Container(
          width: 800,
          child: body,
        )),
      ),
    );
  }
}

class _GameSuggestionState extends State<StatefulGameSuggestions> {
  GameNetworkSource _source = GameNetworkSource();
  Future<List<Game>> _searchResult;
  TextEditingController controller = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchResult = _source.fetchGameSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    Widget searchBar = Container(
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
    Widget futureDetails = FutureBuilder<List<Game>>(
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
            return Text("$snapshot.error");
          }
          return CircularProgressIndicator();
        });

    return Column(
      children: [searchBar, futureDetails],
    );
  }

  onSearchTextChanged(String text) {
    doSearch(text.trim());
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
