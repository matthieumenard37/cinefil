import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_detail.dart';

class MovieList extends StatefulWidget {
  @override
  MovieListState createState() {
    return new MovieListState();
  }
}

class MovieListState extends State<MovieList> {

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

  @override
  Widget build(BuildContext context) {
    getData();
    return new Scaffold(
      backgroundColor: backgroundColor,
      appBar: new AppBar(
        elevation: 0.3,
        centerTitle: true,
        backgroundColor: toolbarBackgroundColor,
//        leading: new Icon(
//          Icons.arrow_back,
//          color: toolbarColor,
//        ),
        title: new Text(
          'CINE ||| FIL',
          style: new TextStyle(color: toolbarColor,
              fontFamily: 'Arvo',
              fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
//          new Icon(
//            Icons.menu,
//            color: toolbarColor,
//          )
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.all(16.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new MovieTitle(mainColor),
            new Expanded(
              child: new ListView.builder(
                  itemCount: movies == null ? 0 : movies.length,
                  itemBuilder: (context, i) {
                    return  new FlatButton(

                      child: new MovieCell(movies,i),
                      padding: const EdgeInsets.all(0.0),
                      onPressed: (){
                        Navigator.push(context, new MaterialPageRoute(builder: (context){
                          return new MovieDetail(movies[i]);
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


  MovieTitle(this.mainColor);

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      child: new Text(
        'All Movies',
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