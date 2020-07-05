import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_detail.dart';
import '../services/authentication.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/favorites.dart';

class MovieList extends StatefulWidget {
  MovieList({Key key, this.userId, this.logoutCallback, this.auth}) : super(key: key);

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  var isFavoritePage = false;
  @override
  MovieListState createState() {
    return new MovieListState();
  }
}

class MovieListState extends State<MovieList> {
  List<Favorite> _favorites;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onFavoriteAddedSubscription;
  StreamSubscription<Event> _onFavoriteChangedSubscription;
  StreamSubscription<Event> _onFavoriteDeleteSubscription;
  Query _favoritesQuery;

  //bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();

    //_checkEmailVerification();

    _favorites = new List();
    _favoritesQuery = _database
        .reference()
        .child("favorite")
        .orderByChild("userId")
        .equalTo(widget.userId);
    _onFavoriteAddedSubscription = _favoritesQuery.onChildAdded.listen(onEntryAdded);
    _onFavoriteChangedSubscription =
        _favoritesQuery.onChildChanged.listen(onEntryChanged);
    _onFavoriteDeleteSubscription = _favoritesQuery.onChildRemoved.listen(onEntryRemoved);
  }
  @override
  void dispose() {
    _onFavoriteAddedSubscription.cancel();
    _onFavoriteChangedSubscription.cancel();
    _onFavoriteDeleteSubscription.cancel();
    super.dispose();
  }
  onEntryChanged(Event event) {
    var oldEntry = _favorites.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    setState(() {
      _favorites[_favorites.indexOf(oldEntry)] =
          Favorite.fromSnapshot(event.snapshot);
    });
  }
  onEntryAdded(Event event) {
    setState(() {
      _favorites.add(Favorite.fromSnapshot(event.snapshot));
    });
  }

  onEntryRemoved(Event event) {
    setState(() {
      log("removing from movie list");
      log(_favorites.length.toString());
      var favoriteFromEvent = Favorite.fromSnapshot(event.snapshot);
      var favoriteToDelete = _favorites.firstWhere((favorite) => favorite.id == favoriteFromEvent.id);
      _favorites.remove(favoriteToDelete);
      log(_favorites.length.toString());
    });
  }
  var movies;
  ///Color mainColor = const Color(0xffff1493);
  Color mainColor = const Color(0xffff69b4);
  Color backgroundColor = const Color(0xff3c345f);
  Color toolbarColor = const Color(0xff9cffff);
  Color toolbarBackgroundColor = const Color(0xff322b4f);

  void getData() async {
    var data = await getJson();

    setState(() {
      movies = data['results'];
    });
  }

  createToolbarButtons() {
    if (widget.isFavoritePage) {
      return <Widget>[
        new IconButton(
          icon: Icon(Icons.movie),
          color: toolbarColor,
          onPressed: () {widget.isFavoritePage = false;},
        )
      ];
    }
    return <Widget>[
      new IconButton(
        icon: Icon(Icons.favorite),
        color: toolbarColor,
        onPressed: () {widget.isFavoritePage = true;},
      )
    ];

  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }


    @override
    Widget build(BuildContext context) {
    getData();

    if (widget.isFavoritePage) {
      List<Map> temporaryMovies = new List();
      for (var index = 0; index < movies.length; ++index) {
        _favorites.forEach((favorite) {
          if (favorite.id == movies[index]["id"])
            temporaryMovies.add(movies[index]);
        });
      }
    movies = temporaryMovies;
    }
    return new Scaffold(
      backgroundColor: backgroundColor,
      appBar: new AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: toolbarBackgroundColor,
        leading: new IconButton(
          icon : Icon(Icons.power_settings_new),
          color: toolbarColor,
          onPressed: signOut,
        ),
        title: new Text(
          'CINE ||| FIL',
          style: new TextStyle(color: toolbarColor,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold),
        ),
        actions: createToolbarButtons(),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new MovieTitle(mainColor, widget.isFavoritePage),
            new Expanded(
              child: new ListView.builder(
                  itemCount: movies == null ? 0 : movies.length,
                  itemBuilder: (context, i) {
                    return  new FlatButton(

                      child: new MovieCell(movies,i),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: (){
                        Navigator.push(context, new MaterialPageRoute(builder: (context){
                          return new MovieDetail(
                              userId: widget.userId,
                              movie: movies[i]);
                        }));
                      },
                      color: backgroundColor,
                    );

                  }),
            )
          ],
        ),
      ),
    );
  }
}

class MovieTitle extends StatelessWidget{

  final Color mainColor;
  final isFavorite;


  MovieTitle(this.mainColor, this.isFavorite);

  @override
  Widget build(BuildContext context) {
    String title = isFavorite ? "Favorites" : 'All Movies';
    return new Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: new Text(
        title,
        style: new TextStyle(
            fontSize: 40.0,
            fontStyle: FontStyle.italic,
            color: Colors.black54,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arvo'
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

}

class MovieCell extends StatelessWidget{

  final movies;
  final i;
  Color subtitleColor = const Color(0xffff69b4);
  Color textColor = const Color(0xff9cffff);
  var image_url = 'https://image.tmdb.org/t/p/w500/';
  MovieCell(this.movies,this.i);

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Row(
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(0.0),
              child: new Container(
                margin: const EdgeInsets.all(16.0),
                child: new Container(
                  width: 70.0,
                  height: 70.0,
                ),
                decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.circular(10.0),
                  color: Colors.grey,
                  image: new DecorationImage(
                      image: new NetworkImage(
                          image_url + movies[i]['poster_path']),
                      fit: BoxFit.cover),
                  boxShadow: [
                    new BoxShadow(
                        color: textColor,
                        blurRadius: 5.0,
                        offset: new Offset(2.0, 5.0))
                  ],
                ),
              ),
            ),
            new Expanded(

                child: new Container(
                  margin: const      EdgeInsets.fromLTRB(16.0,0.0,16.0,0.0),
                  child: new Column(children: [
                    new Text(
                      movies[i]['title'],
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Arvo',
                          fontWeight: FontWeight.bold,
                          color: subtitleColor),
                    ),
                    new Padding(padding: const EdgeInsets.all(2.0)),
                    new Text(movies[i]['overview'],
                      maxLines: 3,
                      style: new TextStyle(
                          color: textColor,
                          fontFamily: 'Arvo'
                      ),)
                  ],
                    crossAxisAlignment: CrossAxisAlignment.start,),
                )
            ),
          ],
        ),
        new Container(
          width: 300.0,
          height: 0.5,
          color: const Color(0xD2D2E1ff),
          margin: const EdgeInsets.all(16.0),
        )
      ],
    );

  }

}

Future<Map> getJson() async {
  var url =
      'http://api.themoviedb.org/3/discover/movie?api_key=57971825def70d432b2c85106046d8ac';
  http.Response response = await http.get(url);
  return json.decode(response.body);
}