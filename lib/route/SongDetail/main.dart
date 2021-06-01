import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String? videoUrl;
  VideoPlayerScreen({Key? key, @required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() {
    return _VideoPlayerScreenState(videoUrl: videoUrl);
  }
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final String? videoUrl;
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  _VideoPlayerScreenState({@required this.videoUrl});

  @override
  void initState() {
    _controller = VideoPlayerController.network(videoUrl!);

    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}

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
    return FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('songs').doc(songId).get(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              appBar: AppBar(
                title: Text(snapshot.data!.data()!['title']),
              ),
              body: Align(
                alignment: Alignment.topCenter,
                child: VideoPlayerScreen(
                  videoUrl: snapshot.data!.data()!['video_url'],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('error initial data'),
            );
          }
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }
}
