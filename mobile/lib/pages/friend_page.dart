import 'package:debtor/models/user.dart';
import 'package:debtor/widgets/user_bar.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class FriendPage extends StatelessWidget {
  final User _friend;
  final Decimal _balance;

  const FriendPage(this._friend, this._balance, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
      body: Column(
        children: [
          UserBar(
            user: _friend,
            totalBalance: _balance,
          )
        ],
      ),
    );
  }
}
