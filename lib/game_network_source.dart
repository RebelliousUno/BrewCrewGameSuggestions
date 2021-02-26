import 'dart:convert';

import 'package:brewcrew/game.dart';
import 'package:brewcrew/prod.dart';
import "package:http/http.dart" as http;

class GameNetworkSource {
  List<Game> _list = [];
  var key = Prod.key;

  Future<void> _setupList() async {
    final response = await http.get(Uri.https('api.rebellious.uno',
        'gamesuggestions/GetGameSuggestions', {"key": key}));
    if (response.statusCode == 200) {
      _list = _getGameList(jsonDecode(response.body));
    } else {
      throw Exception("Failed to get Game Suggestions");
    }
  }

  Future<List<Game>> fetchGameSuggestions(bool played, [bool forceRefresh = false]) async {
    if (_list.isEmpty || forceRefresh) {
      await _setupList();
    }
    return List<Game>.from(_list).where((element) => played != null ? element.getPlayed() == played : true).toList();
  }

  Future<List<Game>> fetchFilteredGame(String text, bool played) async {
    if (_list.isEmpty) {
      await _setupList();
    }
    return _getFilteredGameList(text, played);
  }

  List<Game> getFilteredGameList(String name) {
    return List<Game>.from(_list)
        .where((element) =>
            element.getName().toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  List<Game> _getFilteredGameList(String text, bool played) {
    List<Game> res = List.from(_list);
    res.sort((a, b) => a.getName().compareTo(b.getName()));
    return res
        .where((element) =>
            element.getName().toLowerCase().contains(text.toLowerCase()))
        .where((element) =>
            (played != null) ? element.getPlayed() == played : true)
        .toList();
  }

  List<Game> _getGameList(jsonDecode) {
    List<Game> res = [];
    List<dynamic> items = jsonDecode['Items'];
    items.forEach((element) {
      res.add(Game.fromJson(element));
    });
    res.sort((a, b) => a.getName().compareTo(b.getName()));
    return res;
  }
}
