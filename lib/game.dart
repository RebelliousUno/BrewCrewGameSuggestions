import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Game {
  String _gameName;
  Map<String, String> _suggestedBy;
  bool _played;

  String toString() {
    return _gameName + " " + _played.toString();
  }

  Game(String gameName, Map<String, String> suggestedBy, bool played) {
    this._gameName = gameName;
    this._suggestedBy = suggestedBy;
    this._played = played;
  }

  String getName() {
    return _gameName;
  }

  bool getPlayed() {
    return _played;
  }

  Widget getCard() {
    List<Widget> widgets = [_gameNameRow()];
    widgets.add(Table(
        columnWidths: {0: FlexColumnWidth(1), 1: FlexColumnWidth(2)},
        children: _mapToTableRows(_suggestedBy)));

    widgets.add(Row(children: [
      Expanded(child: Text("Played?")),
      Checkbox(value: _played, onChanged: null)
    ]));
    return Card(
        shape: RoundedRectangleBorder(),
        child: Container(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: widgets,
            )));
  }

  List<TableRow> _mapToTableRows(Map<String, String> map) {
    return map.entries
        .map((entry) => _entryToTableRow(entry.key, entry.value))
        .toList();
  }

  TableRow _entryToTableRow(String who, String why) {
    return TableRow(
        children: [TableCell(child: Text(who)), TableCell(child: Text(why))]);
  }

  Container _gameNameRow() {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          Expanded(child: Text(_gameName, style: TextStyle(fontSize: 18)))
        ]));
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    List<dynamic> s = json["suggested"];
    Map<String, String> suggestions = {};
    s.forEach((element) {
      suggestions.addAll({element["person"]: element["reason"]});
    });
    return Game(json["gamename"], suggestions, json["played"]);
  }
}
