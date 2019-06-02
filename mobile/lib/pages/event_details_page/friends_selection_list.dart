import 'package:debtor/models/event.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/event_details_page/user_selection_list.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/services/friends_service.dart';
import 'package:flutter/material.dart';

FriendsService friendsService = FriendsService();

class FriendsSelectionList extends StatefulWidget {
  const FriendsSelectionList({Key key, this.event}) : super(key: key);
  final Event event;

  @override
  _FriendsSelectionListState createState() => _FriendsSelectionListState();
}

class _FriendsSelectionListState extends State<FriendsSelectionList> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<User>>(
      stream: friendsService.friends,
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return Loader();
        }

        final unaddedFriends = snapshot.data;
        unaddedFriends.removeWhere((u) =>
            widget.event.participants.map((User p) => p.uid).contains(u.uid));

        return Container(child: UserSelectionList(users: unaddedFriends));
      },
    );
  }
}
