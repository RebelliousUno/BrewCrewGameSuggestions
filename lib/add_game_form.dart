import 'dart:convert';

import 'package:brewcrew/prod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class AddGameEntryForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Add a new Game Suggestion",
        home: Scaffold(
            appBar: AppBar(
              title: Center(child: Text('Add a new Game Suggestion')),
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

  final _isLoading = ValueNotifier(false);

  final BuildContext _mainContext;

  AddGameFormState(BuildContext mainContext) : _mainContext = mainContext;

  Widget _createTextFormField(
      String hintText, TextEditingController controller, EdgeInsets padding) {
    return Container(
        padding: padding,
        child: TextFormField(
            controller: controller,
            decoration: InputDecoration(hintText: hintText),
            validator: (value) {
              return value.isEmpty ? 'Please enter some text' : null;
            }));
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets textFieldPadding = EdgeInsets.all(8);
    var person =
        _createTextFormField("Username", usernameController, textFieldPadding);
    var game = _createTextFormField("Game", gameController, textFieldPadding);
    var reason =
        _createTextFormField("Reason", reasonController, textFieldPadding);

    var submitButton = Container(
        padding: textFieldPadding,
        child: ElevatedButton(
          onPressed: () async {
            // Validate returns true if the form is valid, otherwise false.
            if (_formKey.currentState.validate()) {
              setState(() {
                _isLoading.value = true;
              });
              var response = await _req.addGameSuggestion(
                  usernameController.text,
                  gameController.text,
                  reasonController.text);
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
        ));

    return Form(
        key: _formKey,
        child: ValueListenableBuilder(
            valueListenable: _isLoading,
            builder: (context, value, widget) {
              return !value
                  ? Column(
                      children: [person, game, reason, submitButton],
                    )
                  : Center(child: CircularProgressIndicator());
            }));
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
