import 'dart:async';

import 'package:debtor/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

class AuthenticationState {
  const AuthenticationState(this.user);

  bool get isSignedIn => user != null;
  final User user;
}

class Authenticator {
  factory Authenticator() {
    return _instance;
  }
  Authenticator._internal();
  static final Authenticator _instance = Authenticator._internal();

  final _loginState = BehaviorSubject<AuthenticationState>();
  final _firebaseAuth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<void> init() async {
    if (await _googleSignIn.isSignedIn()) {
      final user = await _googleSignIn.signInSilently();
      await _login(user);
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

    final firebaseUser = await _firebaseAuth.signInWithCredential(credential);
    final user = User(firebaseUser.uid, firebaseUser.email,
        firebaseUser.displayName, firebaseUser.photoUrl, true);

    _loginState.add(AuthenticationState(user));
  }
}
