import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Pokemon>> fetchPokemon(http.Client client) async {
  final response = await client.get('https://pokeapi.co/api/v2/pokemon/?limit=151&offset=0');

  return compute(parsePokemon, response.body);
}

List<Pokemon> parsePokemon(String responseBody) {
   var data = json.decode(responseBody);

   final parsed = data["results"].cast<Map<String, dynamic>>();

  return parsed.map<Pokemon>((json) => Pokemon.fromJson(json)).toList();
}

class Pokemon {
  final String name;
  final String url;

  Pokemon({this.name, this.url});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(name: json['name'] as String,
        url: json['url'] as String);
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final appTitle = 'My Pokedex';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      home: MyHomePage(title: appTitle),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Pokemon>>(
          future: fetchPokemon(http.Client()),
          builder: (context, snapshot) {
            if (snapshot.hasError) print(snapshot.error);

            return snapshot.hasData
                ? PokemonList(pokemon: snapshot.data)
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class PokemonList extends StatelessWidget {
  final List<Pokemon> pokemon;

  PokemonList({Key key, this.pokemon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    final imageUrl = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/";

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) {
        return Card(
          child: new Container(
            padding: EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                Image.network(imageUrl + (index + 1).toString() + ".png"),
                Text(pokemon[index].name,
                style: TextStyle(
                  fontSize: 16
                ),)
              ],
            ),
          ),
        );
      },
    );
  }
}
