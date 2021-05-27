import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeSongModel extends ChangeNotifier {
  var _snapshot;
  HomeSongModel(
    var snapshot,
  ) {
    this._snapshot = snapshot;
    notifyListeners();
  }
  get snapshot => this._snapshot;
}

class HomeUserLikedModel extends ChangeNotifier {
  var _snapshot;
  HomeUserLikedModel(var snapshot) {
    this._snapshot = snapshot;
    notifyListeners();
  }
  get userLikesSnapshot => this._snapshot;
}

// class UserStateModel extends ChangeNotifier {
//   signInWithGoogle() async {
//     final googleProvider = GoogleAuthProvider();
//     googleProvider
//         .addScope('https://www.googleapis.com/auth/contacts.readonly');
//     googleProvider.setCustomParameters({'login_hint': 'user@example.com'});
//     return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
//   }

//   signInWithApple() async {
//     final provider =
//         OAuthProvider("apple.com").addScope('email').addScope('name');
//     return await FirebaseAuth.instance.signInWithRedirect(provider);
//   }
// }
