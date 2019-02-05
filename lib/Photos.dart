import 'package:cloud_firestore/cloud_firestore.dart';

class Photos {

  final String url, title, date;
  final int like;
  final DocumentReference reference;

  Photos.fromMap(Map<String, dynamic> map,{this.reference})
      : assert(map['date'] != null),
        assert(map['like'] != null),
        assert(map['url'] != null),
        assert(map['title'] != null),
        url = map['url'],
        title = map['title'],
        like = map['like'],
        date = map['date'];

  void updateLike(){
    Firestore.instance.runTransaction((transaction) async {
      await transaction
          .update(reference, {'like': this.like + 1});
    });
  }
  Photos.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data,reference: snapshot.reference);
}