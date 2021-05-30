import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pjsekai_upvote/route/Home/main.dart';
import 'package:pjsekai_upvote/route/SongDetail/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AppsRouting());
}

class AppsRoutePath {
  final songId;
  final isUnknown;

  AppsRoutePath.home()
      : songId = '',
        isUnknown = false;

  AppsRoutePath.details(this.songId) : isUnknown = false;
  AppsRoutePath.unknown()
      : songId = '',
        isUnknown = true;

  get isHomePage => songId == '';
  get isDetailsPage => songId != '';
}

class AppsRouteInformationParser extends RouteInformationParser<AppsRoutePath> {
  @override
  Future<AppsRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location.toString());
    if (uri.pathSegments.length == 0) {
      return AppsRoutePath.home();
    }
    if (uri.pathSegments.length == 1) {
      return AppsRoutePath.details(uri.pathSegments[0]);
    }
    return AppsRoutePath.unknown();
  }

  @override
  RouteInformation? restoreRouteInformation(AppsRoutePath configuration) {
    if (configuration.isUnknown) {
      return RouteInformation(location: '/404');
    }
    if (configuration.isHomePage) {
      return RouteInformation(location: '/');
    }
    if (configuration.isDetailsPage) {
      return RouteInformation(location: '/${configuration.songId}');
    }
    return null;
  }
}

class AppsRouteDelegate extends RouterDelegate<AppsRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppsRoutePath> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  final GlobalKey<NavigatorState> navigatorKey;

  AppsRouteDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  var _songId = '';
  var show404 = false;

  void onTapSelectSongs(var song) {
    _songId = song;
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
          key: ValueKey('AppsHome'),
          child: FutureBuilder(
            // Initialize FlutterFire:
            future: _initialization,
            builder: (context, snapshot) {
              // Check for errors
              if (snapshot.hasError) {
                return Center(
                  child: Text('initial error'),
                );
              }

              // Once complete, show your application
              if (snapshot.connectionState == ConnectionState.done) {
                return MyHomePage(
                  onTapSelectSongs: onTapSelectSongs,
                );
              }

              // Otherwise, show something whilst waiting for initialization to complete
              return CircularProgressIndicator();
            },
          ),
        ),
        if (_songId != '') SongDetailpage(songId: _songId),
      ],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _songId = '';
        show404 = false;
        notifyListeners();
        return true;
      },
    );
  }

  get currentConfiguration {
    if (show404) {
      return AppsRoutePath.unknown();
    }
    return _songId == ''
        ? AppsRoutePath.home()
        : AppsRoutePath.details(_songId);
  }

  @override
  Future<void> setNewRoutePath(AppsRoutePath configuration) async {
    if (configuration.isUnknown) {
      _songId = '';
      show404 = true;
      return;
    }
    if (configuration.isDetailsPage) {
      if (configuration.songId != '') {
        _songId = configuration.songId;
      } else {
        _songId = '';
      }
    }
    show404 = false;
  }
}

class AppsRouting extends StatefulWidget {
  @override
  _AppsRoutingState createState() {
    return _AppsRoutingState();
  }
}

class _AppsRoutingState extends State<AppsRouting> {
  var _routeInformationParser = AppsRouteInformationParser();
  var _routerDelegate = AppsRouteDelegate();
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        title: 'PjSekai wishlist songs',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
        routeInformationParser: _routeInformationParser,
        routerDelegate: _routerDelegate);
  }
}
