import 'package:flutter/material.dart';

class EditableList extends StatelessWidget {
  const EditableList({Key key, this.content, this.header, this.footer})
      : super(key: key);
  final Widget content;
  final Widget header;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List<Widget>.from(<Widget>[header])
              ..add(content)
              ..add(footer)));
  }
}
