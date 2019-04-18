import 'package:debtor/pages/books_page.dart';
import 'package:flutter/material.dart';

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
    _HomePageEntry(Container(), 'Friends', Icons.people),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debtor'),
      ),
      body: _contents[_currentIdx].Body,
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIdx,
          onTap: _onTabTapped,
          items: _contents.map(_toNavigationItem).toList()),
    );
  }

  BottomNavigationBarItem _toNavigationItem(_HomePageEntry entry) {
    return BottomNavigationBarItem(
        icon: Icon(entry.Icon), title: Text(entry.Title));
  }

  void _onTabTapped(int idx) {
    setState(() {
      _currentIdx = idx;
    });
  }
}

class _HomePageEntry {
  final Widget Body;
  final String Title;
  final IconData Icon;
  const _HomePageEntry(this.Body, this.Title, this.Icon);
}
