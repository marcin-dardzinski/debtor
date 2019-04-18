import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/friends_service.dart';
import 'package:debtor/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Authenticator authenticator = Authenticator();
FriendsService friends = FriendsService();

class FriendsPage extends StatelessWidget {
  final mockUser = User('adsf', 'andrzej@duda.com', 'Andrzej Duda',
      'https://pbs.twimg.com/profile_images/556495456805453826/wKEOCDN0_400x400.png');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CurrentUserBar(
          user: mockUser,
        ),
        const Divider(),
        StreamBuilder<List<User>>(
          stream: friends.friends,
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (ctx, idx) {
                    return idx < snapshot.data.length
                        ? _friendTile(snapshot.data[idx])
                        : _addFriendButton();
                  }),
            );
          },
        ),
      ],
    );
  }

  Widget _friendTile(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.avatar),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
    );
  }

  Widget _addFriendButton() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
      child: RaisedButton(
        child: const Text('Add friend'),
        onPressed: () {},
      ),
    );
  }
}

class CurrentUserBar extends StatelessWidget {
  final User user;
  const CurrentUserBar({Key key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      // color: Colors.grey,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(user.avatar),
              radius: 40,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    user.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Text(
                  user.email,
                  textAlign: TextAlign.start,
                  style: const TextStyle(fontSize: 12),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
