import 'dart:convert';

import 'package:brewcrew/prod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class AddGameEntryForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Add a new Game Suggestion",
        home: Scaffold(
            appBar: AppBar(
              title: Text('Add a new Game Suggestion'),
            ),
            body: Center(
                child: Container(width: 800, child: AddGameForm(context)))));
  }
}

class AddGameForm extends StatefulWidget {
  final BuildContext _context;

  AddGameForm(BuildContext context) : _context = context;

  @override
  State<StatefulWidget> createState() {
    return AddGameFormState(_context);
  }
}

class AddGameFormState extends State<AddGameForm> {
  final _formKey = GlobalKey<FormState>();
  var _req = AddGameSuggestionRequest();
  var usernameController = TextEditingController();
  var reasonController = TextEditingController();
  var gameController = TextEditingController();
  final BuildContext _mainContext;

  AddGameFormState(BuildContext mainContext) : _mainContext = mainContext;

  @override
  Widget build(BuildContext context) {
    var person = TextFormField(
      controller: usernameController,
      decoration: InputDecoration(hintText: "Username"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
    var game = TextFormField(
      controller: gameController,
      decoration: InputDecoration(hintText: "Game"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    var reason = TextFormField(
      decoration: InputDecoration(hintText: "Reason"),
      controller: reasonController,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    var submitButton = ElevatedButton(
      onPressed: () async {
        // Validate returns true if the form is valid, otherwise false.
        if (_formKey.currentState.validate()) {
          var response = await _req.addGameSuggestion(usernameController.text,
              gameController.text, reasonController.text);
          showDialog(
              context: context,
              builder: (BuildContext alertContext) {
                return AlertDialog(
                  title: Text("Alert Title"),
                  content: Text(response),
                  actions: [
                    TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(alertContext).pop();
                          Navigator.of(_mainContext).pop();
                        }),
                  ],
                );
              });
        }
      },
      child: Text('Submit'),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [person, game, reason, submitButton],
      ),
    );
  }
}

class AddGameSuggestionRequest {
  var key = Prod.key;

  Future<String> addGameSuggestion(String who, String game, String why) async {
    var response = await http.post(
        Uri.https('api.rebellious.uno', 'gamesuggestions/AddGameSuggestion'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'key': key,
          "game": game,
          "who": who,
          "why": why,
        }));
    switch (response.statusCode) {
      case 200:
        {
          return response.body;
        }
        break;
      case 409:
        {
          return "You've already suggested that game";
        }
        break;
      default:
        {
          return "Something went wrong";
        }
        break;
    }
  }
}
