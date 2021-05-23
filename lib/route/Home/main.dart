import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  createState() {
    return _MyHomePageState();
  }
}

class _MyHomePageState extends State<MyHomePage> {
  var _songsStream = FirebaseFirestore.instance.collection('songs').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PjSekai wishlist songs'),
      ),
      body: StreamBuilder(
          stream: _songsStream,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('error fetch data'),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return Center(
              child: Container(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: listOfSongs(snapshot)),
            );
          }),
    );
  }

  thumbnailImage(var url) {
    return Container(
      height: 320,
      color: Colors.grey,
      child: Center(
        child: Image(image: NetworkImage(url)),
      ),
    );
  }

  title(var title) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 8),
      child: Text(title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  creator(var creator) {
    return Container(
      margin: EdgeInsets.only(top: 4, left: 8),
      child: Text(
        creator,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  upvoteButton() {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 8),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  height: 108,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          height: 32,
                          child: ElevatedButton(
                              onPressed: () {},
                              child: Text('Vote with google account'))),
                      Container(
                          width: double.infinity,
                          height: 32,
                          margin: EdgeInsets.only(top: 8),
                          child: OutlinedButton(
                              onPressed: () {},
                              child: Text('Vote with apple account')))
                    ],
                  ),
                );
              });
        },
        child: Icon(
          Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    );
  }

  likesCount(var likesCount) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 8),
      child: Text('$likesCount likes'),
    );
  }

  listOfSongs(var snapshot) {
    return ListView.builder(
        itemCount: snapshot.data.docs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: Card(
                child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  thumbnailImage(snapshot.data.docs[index]['thumbnail']),
                  title(snapshot.data.docs[index]['title']),
                  creator(snapshot.data.docs[index]['creator']),
                  likesCount(snapshot.data.docs[index]['likes']),
                  upvoteButton(),
                ],
              ),
            )),
          );
        });
  }
}
