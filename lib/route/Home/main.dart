import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class _ActionLists extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _UpvoteIcon extends StatelessWidget {
  final homeSongData;
  final userLikesData;
  _UpvoteIcon({@required this.homeSongData, @required this.userLikesData});
  _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoggedIn() &&
        userLikesData.contains(FirebaseAuth.instance.currentUser?.uid)) {
      return Icon(
        Icons.favorite,
        color: Colors.red,
      );
    }
    return Icon(
      Icons.favorite_outline,
      color: Colors.red,
    );
  }
}

class _UpvoteButton extends StatelessWidget {
  final userLikesData;
  final homeSongData;
  _UpvoteButton({@required this.homeSongData, this.userLikesData});
  _signInWithGoogle() async {
    final googleProvider = GoogleAuthProvider();
    return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
  }

  _signInWithApple() async {
    // Create and configure an OAuthProvider for Sign In with Apple.
    final provider = OAuthProvider("apple.com");

    // Sign in the user with Firebase.
    return await FirebaseAuth.instance.signInWithRedirect(provider);
  }

  _isUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  _handleLikesClick(context) async {
    var songId = homeSongData.id;
    var batch = FirebaseFirestore.instance.batch();
    if (userLikesData.contains(FirebaseAuth.instance.currentUser?.uid)) {
      try {
        FirebaseFirestore.instance.collection('songs').doc(songId).update({
          'user_likes': userLikesData.where((x) {
            return x != FirebaseAuth.instance.currentUser?.uid;
          }).toList(),
          'likes': homeSongData['likes'] - 1,
        });
        await batch.commit();
      } catch (err) {}
    } else {
      userLikesData.add(FirebaseAuth.instance.currentUser?.uid);
      var totalLikes = homeSongData['likes'];
      totalLikes += 1;
      try {
        batch.update(
            FirebaseFirestore.instance.collection('songs').doc(homeSongData.id),
            {
              'likes': totalLikes,
              'user_likes': userLikesData,
            });
        await batch.commit();
      } catch (err) {
        print(err.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 8, left: 8),
        child: GestureDetector(
          onTap: () {
            if (_isUserLoggedIn()) {
              // print('lewaat');
              _handleLikesClick(context);
            } else {
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
                                  onPressed: () {
                                    _signInWithGoogle();
                                  },
                                  child: Text('Vote with google account'))),
                          Container(
                              width: double.infinity,
                              height: 32,
                              margin: EdgeInsets.only(top: 8),
                              child: OutlinedButton(
                                  onPressed: () {
                                    _signInWithApple();
                                  },
                                  child: Text('Vote with apple account')))
                        ],
                      ),
                    );
                  });
            }
          },
          child: _UpvoteIcon(
            homeSongData: homeSongData,
            userLikesData: userLikesData,
          ),
        ));
  }
}

class _LikesCount extends StatelessWidget {
  final data;
  _LikesCount({@required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8, top: 8),
      child: Text('$data likes'),
    );
  }
}

class _Creator extends StatelessWidget {
  final data;
  _Creator({@required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4, left: 8),
      child: Text(
        data,
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  final data;
  _Title({@required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 8, left: 8),
      child: Text(data,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  final data;
  _ThumbnailImage({@required this.data});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      color: Colors.grey,
      child: Center(
        child: Image(image: NetworkImage(data)),
      ),
    );
  }
}

class _ListOfSongs extends StatelessWidget {
  final onTapSelectSongs;
  final snapshot;
  _ListOfSongs({@required this.snapshot, @required this.onTapSelectSongs});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: snapshot.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () {
                  this.onTapSelectSongs(snapshot[index]['title']);
                },
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ThumbnailImage(
                          data: snapshot[index]['thumbnail'],
                        ),
                        _Title(
                          data: snapshot[index]['title'],
                        ),
                        _Creator(
                          data: snapshot[index]['creator'],
                        ),
                        _LikesCount(
                          data: snapshot[index]['likes'],
                        ),
                        _UpvoteButton(
                          homeSongData: snapshot[index],
                          userLikesData: snapshot[index]['user_likes'],
                        )
                      ],
                    ),
                  ),
                )),
          );
        });
  }
}

class MyHomePage extends StatelessWidget {
  final onTapSelectSongs;
  MyHomePage({@required this.onTapSelectSongs});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            appBar: AppBar(
              title: Text('PjSekai Wishlist Songs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  tooltip: 'Show Snackbar',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Testing for next')));
                  },
                ),
              ],
            ),
            body: _ListOfSongs(
              onTapSelectSongs: onTapSelectSongs,
              snapshot: snapshot.data?.docs,
            ),
          );
        });
  }
}
