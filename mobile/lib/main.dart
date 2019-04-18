import 'package:debtor/authenticator.dart';
import 'package:debtor/home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Authenticator authenticator;

void main() {
  authenticator = Authenticator()..init();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => StreamBuilder<AuthenticationState>(
                stream: authenticator.loggedInUser,
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return Loader();
                  }

                  return snapshot.data.isSignedIn ? HomePage() : LoginPage();
                },
              )
        });
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debtor'),
      ),
      body: Center(
        child: RaisedButton(
          child: const Text('Sign in'),
          onPressed: _signIn,
        ),
      ),
    );
  }

  void _signIn() {
    authenticator.signIn();
  }
}

class Loader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
