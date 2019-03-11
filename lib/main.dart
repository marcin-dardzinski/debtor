import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Login'),
          ),
          body: Login()),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BookList(),
    );
  }
}

class Login extends StatefulWidget {
  @override
  LoginState createState() {
    return LoginState();
  }
}

class LoginState extends State<Login> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RaisedButton(
            child: const Text('Sign in'),
            onPressed: _signIn,
          ),
          RaisedButton(
            child: const Text('Log out'),
            onPressed: _logOut,
          )
        ],
      ),
    );
  }

  Future _signIn() async {
    final account = await _googleSignIn.signIn();
    final auth = await account.authentication;

    final credentials = GoogleAuthProvider.getCredential(
        idToken: auth.idToken, accessToken: auth.accessToken);
    final user = await _auth.signInWithCredential(credentials);

    setState(() {
      _user = user;
    });
  }

  Future _logOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _user = null;
    });
  }
}

class BookList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          Firestore.instance.collection('books').orderBy('title').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Text('Waiting');
          default:
            final books = snapshot.data.documents;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (ctx, idx) {
                final book = books[idx];
                return ListTile(
                  title: Text(book['title']),
                  subtitle: Text(book['author'] ?? ''),
                );
              },
            );
        }
      },
    );
  }
}
