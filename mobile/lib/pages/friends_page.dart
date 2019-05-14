import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/friends_service.dart';
import 'package:debtor/helpers.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

Authenticator authenticator = Authenticator();
FriendsService friends = FriendsService();

Observable<Tuple2<AuthenticationState, Decimal>> _combineUserAndTotalBalance() {
  return Observable.combineLatest2(
      authenticator.loggedInUser, friends.myTotalBalance,
      (AuthenticationState auth, Decimal balance) {
    return Tuple2(auth, balance);
  });
}

Observable<List<Tuple2<User, Decimal>>> _combineFriendsAndBalaces() {
  return Observable.combineLatest2(friends.friends, friends.myBalances,
      (List<User> friends, List<Balance> balances) {
    final balancesMap = Map<String, Decimal>.fromIterable(balances,
        key: (dynamic b) => b.otherUserId, value: (dynamic b) => b.amount);

    return friends.map((friend) {
      final amount = balancesMap[friend.uid] ?? Decimal.fromInt(0);
      return Tuple2(friend, amount);
    }).toList();
  });
}

class FriendsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StreamBuilder<Tuple2<AuthenticationState, Decimal>>(
            stream: _combineUserAndTotalBalance(),
            builder: (ctx, snapshot) {
              if (snapshot.hasData && snapshot.data.item1.user != null) {
                return CurrentUserBar(
                  user: snapshot.data.item1.user,
                  totalBalance: snapshot.data.item2,
                );
              }
              return Container();
            }),
        const Divider(),
        StreamBuilder<List<Tuple2<User, Decimal>>>(
          stream: _combineFriendsAndBalaces(),
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            }

            return Expanded(
              child: ListView.builder(
                  itemCount: snapshot.data.length + 1,
                  itemBuilder: (ctx, idx) {
                    return idx < snapshot.data.length
                        ? _friendTile(
                            snapshot.data[idx].item1, snapshot.data[idx].item2)
                        : _addFriendButton(ctx);
                  }),
            );
          },
        ),
      ],
    );
  }

  Widget _friendTile(User user, Decimal balance) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.avatar),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      trailing: Container(
          margin: const EdgeInsets.only(right: 8),
          child: Text(
            balance.toStringAsFixed(2),
            style: TextStyle(color: getColorForBalance(balance)),
          )),
    );
  }

  Widget _addFriendButton(BuildContext ctx) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
      child: RaisedButton(
        child: const Text('Add friend'),
        onPressed: () async {
          final newFriend = await showSearch(
            context: ctx,
            delegate: AddFriendDelegate(),
            query: '',
          );
          if (newFriend != null) {
            await friends.addFriend(newFriend);
          }
        },
      ),
    );
  }
}

class CurrentUserBar extends StatelessWidget {
  final User user;
  final Decimal totalBalance;
  const CurrentUserBar({Key key, this.user, this.totalBalance})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Text(
              totalBalance.toStringAsFixed(2),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: getColorForBalance(totalBalance),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddFriendDelegate extends SearchDelegate<User> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => _searchFriends(context);

  @override
  Widget buildSuggestions(BuildContext context) => _searchFriends(context);

  Widget _searchFriends(BuildContext context) {
    if (query.length < 2) {
      return Container();
    }

    return FutureBuilder<List<User>>(
      future: friends.searchFriends(query),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final matches = snapshot.data;

        if (matches.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return ListView.builder(
          itemCount: matches.length,
          itemBuilder: (ctx, idx) => _friendTile(matches[idx], ctx),
        );
      },
    );
  }

  Widget _friendTile(User user, BuildContext ctx) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(user.avatar),
      ),
      title: Text(user.name),
      subtitle: Text(user.email),
      onTap: () {
        close(ctx, user);
      },
    );
  }
}
