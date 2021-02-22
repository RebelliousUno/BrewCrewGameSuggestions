import 'dart:convert';

import 'package:brewcrew/game.dart';
import "package:http/http.dart" as http;


class GameNetworkSource {
  List<Game> _list = [];
  String key = "";

  Future<List<Game>> fetchGameSuggestions() async {
    if (!_list.isEmpty) {
      return List.from(_list);
    }
    final response = await http.get(Uri.https(
        'api.rebellious.uno', 'gamesuggestions/GetGameSuggestions',
        {"key": key}));
    if (response.statusCode == 200) {
      _list = _getGameList(jsonDecode(response.body));
      return List.from(_list);
    } else {
      throw Exception("Failed to get Game Suggestions");
    }
  }

  Future<List<Game>> fetchFilteredGame(String text) async {
    if (!_list.isEmpty) {
      return _getFilteredGameList(text);
    }
    final response = await http.get(Uri.https(
        'api.rebellious.uno', 'gamesuggestions/GetGameSuggestions',
        {"key": key}));
    if (response.statusCode == 200) {
        _list = _getGameList(jsonDecode(response.body));
      return _getFilteredGameList(text);
    } else {
      throw Exception("Failed to get Game Suggestions");
    }
  }

  List<Game> getFilteredGameList(String name) {
    return List<Game>.from(_list)
        .where((element) =>
        element.getName().toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  List<Game> _getFilteredGameList(String text) {
    List<Game> res = List.from(_list);
    res.sort((a, b) => a.getName().compareTo(b.getName()));
    return res.where((element) => element.getName().toLowerCase().contains(text.toLowerCase())).toList();
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