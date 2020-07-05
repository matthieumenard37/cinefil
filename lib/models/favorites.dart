import 'package:firebase_database/firebase_database.dart';

class Favorite {
  String key;
  int id;
  String userId;

  Favorite(this.id, this.userId);

  Favorite.fromSnapshot(DataSnapshot snapshot) :
        key = snapshot.key,
        userId = snapshot.value["userId"],
        id = snapshot.value["id"];

  toJson() {
    return {
      "id": id,
      "userId": userId,
    };
  }
}