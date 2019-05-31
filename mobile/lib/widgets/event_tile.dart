import 'package:debtor/models/event.dart';
import 'package:debtor/widgets/stacked_user_avatars.dart';
import 'package:flutter/material.dart';

class EventTile extends StatefulWidget {
  const EventTile({Key key, this.event, this.onTap}) : super(key: key);
  final Event event;
  final Function onTap;

  _EventTileState createState() => _EventTileState();
}

class _EventTileState extends State<EventTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: StackedUserAvatars(
            users: widget.event.participants,
            avatarRadius: 20,
            avatarSpacing: 20),
        title: Text(widget.event.name),
        onTap: widget.onTap);
  }
}
