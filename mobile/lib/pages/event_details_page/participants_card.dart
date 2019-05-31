import 'package:debtor/models/event.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/event_details_page/friends_selection_list.dart';
import 'package:debtor/pages/event_details_page/user_editable_list.dart';
import 'package:flutter/material.dart';

class ParticipantsCard extends StatelessWidget {
  const ParticipantsCard({Key key, this.onAdd, this.event, this.onDelete})
      : super(key: key);
  final Function onAdd;
  final Function onDelete;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return UserEditableList(
        users: event.participants,
        onAdd: () => showDialog<List<User>>(
                context: context,
                builder: (ctx) => FriendsSelectionList(event: event)).then((u) {
              u.forEach(onAdd);
            }),
        onDelete: onDelete);
  }
}
