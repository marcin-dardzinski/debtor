import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookListPage extends StatelessWidget {
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
