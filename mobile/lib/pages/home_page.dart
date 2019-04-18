import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debtor'),
      ),
      body: const Text('data'),
      bottomNavigationBar: BottomNavigationBar(currentIndex: 0, items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Home'),
        ),
        const BottomNavigationBarItem(
            icon: Icon(Icons.person), title: Text('Friends'))
      ]),
    );
  }
}
