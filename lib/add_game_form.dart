import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddGameEntryForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Add a new Game Suggestion",
        home: Scaffold(
            appBar: AppBar(
              title: Text('Add a new Game Suggestion'),
            ),
            body: Center(child: Container(width: 800, child: AddGameForm()))));
  }
}

class AddGameForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return AddGameFormState();
  }
}

class AddGameFormState extends State<AddGameForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var t = TextFormField(
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );

    var b = ElevatedButton(
      onPressed: () {
        // Validate returns true if the form is valid, otherwise false.
        if (_formKey.currentState.validate()) {
          // If the form is valid, display a snackbar. In the real world,
          // you'd often call a server or save the information in a database.

          Scaffold.of(context)
              .showSnackBar(SnackBar(content: Text('Processing Data')));
        }
      },
      child: Text('Submit'),
    );

    return Form(
      key: _formKey,
      child: Column(
        children: [t, b],
      ),
    );
  }
}
