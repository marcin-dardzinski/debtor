import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationState {
  const AuthenticationState(this.user);

  bool get isSignedIn => user != null;
  final FirebaseUser user;
}

class Authenticator {
  final _loginState = PublishSubject<AuthenticationState>();
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<void> init() async {
    if (await _googleSignIn.isSignedIn()) {
      await _login(_googleSignIn.currentUser);
    } else {
      _loginState.add(const AuthenticationState(null));
    }
  }

  Future<bool> signIn() async {
    final user = await _googleSignIn.signIn();
    if (user == null) {
      return false;
    }

    _loginState.add(null);
    await _login(user);
    return true;
  }

  Stream<AuthenticationState> get loggedInUser => _loginState.stream;

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    _loginState.add(const AuthenticationState(null));
  }

  Future<void> _login(GoogleSignInAccount account) async {
    final auth = await account.authentication;

    final credential = GoogleAuthProvider.getCredential(
        idToken: auth.idToken, accessToken: auth.accessToken);

    final user = await _firebaseAuth.signInWithCredential(credential);
    _loginState.sink.add(AuthenticationState(user));
  }
}
