import 'package:debtor/helpers.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/event_details_page/editable_list.dart';
import 'package:debtor/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class UserEditableList extends StatelessWidget {
  const UserEditableList({Key key, this.users, this.onAdd, this.onDelete})
      : super(key: key);
  final List<User> users;
  final Function onAdd;
  final Function onDelete;

  Widget _buildItemTile(User user) {
    return Dismissible(
      key: Key(user.uid),
      child: ListTile(
          leading: UserAvatar(avatar: user.avatar),
          title: Text(displayUserNameWithYouIndicator(user))),
      onDismissed: (direction) => onDelete(user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditableList(
      header: ListTile(
          leading: const Icon(Icons.group), title: const Text('Participants')),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: users.length,
        itemBuilder: (BuildContext ctx, int index) {
          return _buildItemTile(users[index]);
        },
      ),
      footer: ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Add participant'),
        onTap: onAdd,
      ),
    );
  }
}
