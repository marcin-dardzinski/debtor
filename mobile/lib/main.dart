import 'package:debtor/authenticator.dart';
import 'package:debtor/pages/books_page.dart';
import 'package:debtor/pages/friends_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stetho/flutter_stetho.dart';

Authenticator authenticator;

void main() {
  Stetho.initialize();
  authenticator = Authenticator()..init();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentIdx = 0;
  final List<_HomePageEntry> _contents = [
    _HomePageEntry(BookListPage(), 'Home', Icons.home),
    _HomePageEntry(FriendsPage(), 'Friends', Icons.people),
  ];

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
      body: _contents[_currentIdx].body,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIdx,
          onTap: _onTabTapped,
          items: _contents.map(_toNavigationItem).toList()),
    );
  }

  BottomNavigationBarItem _toNavigationItem(_HomePageEntry entry) {
    return BottomNavigationBarItem(
        icon: Icon(entry.icon), title: Text(entry.title));
  }

  void _onTabTapped(int idx) {
    setState(() {
      _currentIdx = idx;
    });
  }
}

class _HomePageEntry {
  const _HomePageEntry(this.body, this.title, this.icon);
  final Widget body;
  final String title;
  final IconData icon;
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
