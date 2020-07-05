import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:flutterapptest2/models/favorites.dart';

class MovieDetail extends StatefulWidget {
  MovieDetail({Key key, this.userId, this.movie}) : super(key: key);

  final Map movie;
  final String userId;

  @override
  MovieDetailState createState() {
    return new MovieDetailState();
  }
}

class MovieDetailState extends State<MovieDetail> {
  List<Favorite> _favorites;

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final _textEditingController = TextEditingController();
  StreamSubscription<Event> _onFavoriteAddedSubscription;
  StreamSubscription<Event> _onFavoriteChangedSubscription;
  StreamSubscription<Event> _onFavoriteDeleteSubscription;
  Query _favoritesQuery;

  //bool _isEmailVerified = false;

  addNewFavorite(int id) {
    if (id != null) {
      Favorite favorite = new Favorite(id, widget.userId);
      _database.reference().child("favorite").push().set(favorite.toJson());
    }
  }

  deleteFavorite(String favoriteId, int index) {
    _database.reference().child("favorite").child(favoriteId).remove().then((_) {
      print("Delete $favoriteId successful");
      setState(() {
        _favorites.removeAt(index);
      });
    });
  }

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
      _favorites.remove(Favorite.fromSnapshot(event.snapshot));
    });
  }
  var image_url = 'https://image.tmdb.org/t/p/w500/';

  createFloatingActionButton() {
    var movieId = widget.movie["id"];
    var isFavorite = false;
    var index = -1;

    _favorites.forEach((favorite) {
      if (favorite.id == movieId) {
        isFavorite = true;
        index = _favorites.indexOf(favorite);
      }
    });
    if (isFavorite) {
      return FloatingActionButton(
        onPressed: () {
          deleteFavorite(_favorites[index].key, index);
        },
        child: Icon(Icons.favorite)
      );
    }
    return FloatingActionButton(
        onPressed: () {
          addNewFavorite(movieId);
        },
        child: Icon(Icons.favorite_border)
    );
  }


  Color mainColor = const Color(0xff3C3261);

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      body: new Stack(
        fit: StackFit.expand,
        children: <Widget>[
          new Image.network(image_url + widget.movie['poster_path'], fit: BoxFit.cover,),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 5.0,sigmaY: 5.0),
            child: new Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          new SingleChildScrollView(
            child: new Container(
              margin: const EdgeInsets.all(20.0),
              child: new Column(
                  children: <Widget>[
                    new Container(
                      alignment: Alignment.center,
                      child: new Container(width: 400.0, height: 400.0,),
                      decoration: new BoxDecoration(
                          borderRadius: new BorderRadius.circular(10.0),
                          image: new DecorationImage(image: new NetworkImage(image_url+widget.movie['poster_path']),fit: BoxFit.cover),
                          boxShadow: [
                            new BoxShadow(
                                color: Colors.black,
                                blurRadius: 20.0,
                                offset: new Offset(0.0, 10.0)
                            )
                          ]
                      ),
                    ),
                    new Container(
                      margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 0.0),
                      child: new Row(
                        children: <Widget>[
                          new Expanded(child: new Text(widget.movie['title'], style: new TextStyle(color: Colors.white, fontSize: 30.0, fontFamily: 'Arvo'),)),
                          new Text('${widget.movie['vote_average']}/10',style: new TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'Arvo'),)
                        ],
                      ),
                    ),
                    new Text(widget.movie['overview'], style: new TextStyle(color: Colors.white, fontFamily: 'Arvo')),
                    new Padding(
                        padding: const EdgeInsets.all(10.0)),
//
                  ]
              ),
            ),
          )
        ],
      ),
      floatingActionButton: createFloatingActionButton(),
    );
  }
}