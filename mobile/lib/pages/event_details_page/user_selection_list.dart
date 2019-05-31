import 'package:debtor/models/user.dart';
import 'package:debtor/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class UserSelectionList extends StatefulWidget {
  const UserSelectionList({Key key, this.users}) : super(key: key);
  final List<User> users;

  @override
  _UserSelectionListState createState() => _UserSelectionListState();
}

class _UserSelectionListState extends State<UserSelectionList> {
  List<User> selectedUsers = <User>[];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add friends'),
      content: ListView.builder(
        itemCount: widget.users.length,
        itemBuilder: (BuildContext ctx, int index) {
          return Column(children: <Widget>[
            CheckboxListTile(
                title: Text(widget.users[index].name),
                secondary: UserAvatar(avatar: widget.users[index].avatar),
                value: selectedUsers.contains(widget.users[index]),
                onChanged: (bool value) {
                  setState(() {
                    value
                        ? selectedUsers.add(widget.users[index])
                        : selectedUsers.remove(widget.users[index]);
                  });
                }),
          ]);
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('Submit'),
          onPressed: () => Navigator.pop(context, selectedUsers),
        )
      ],
    );
  }
}
