import 'package:debtor/authenticator.dart';
import 'package:debtor/pages/event_form.dart';
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

                  return snapshot.data.isSignedIn
                      ? BookListPage()
                      : LoginPage();
                },
              )
        });
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
      body: BookListPage(),
    );
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

class BookListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Debtor'),
          actions: [
            PopupMenuButton<bool>(
              itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      child: Text('Logout'),
                      value: true,
                    )
                  ],
              onSelected: (_) => authenticator.logout(),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('books')
              .orderBy('title')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (ctx) => Scaffold(
                resizeToAvoidBottomPadding: false,
                appBar: AppBar(
                  title: const Text("Add event"),
                  actions: <Widget>[
                    IconButton(icon: Icon(Icons.check), onPressed: () {},)
                  ],
                ),
                backgroundColor: Colors.grey[300],
                body: EventForm(),
                )
              )
            );
          },
          child: Icon(Icons.add),
        ),
        );
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
