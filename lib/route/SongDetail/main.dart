import 'package:flutter/material.dart';

class SongDetailpage extends Page {
  final songId;
  SongDetailpage({
    @required this.songId,
  }) : super(key: ValueKey(songId));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
        settings: this,
        builder: (BuildContext context) {
          return SongDetailScreen(
            songId: songId,
          );
        });
  }
}

class SongDetailScreen extends StatelessWidget {
  final songId;
  SongDetailScreen({
    @required this.songId,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(songId),
      ),
      body: Center(
        child: Text('center'),
      ),
    );
  }
}
