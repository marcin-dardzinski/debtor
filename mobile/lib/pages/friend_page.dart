import 'package:debtor/authenticator.dart';
import 'package:debtor/forms/payment_form.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/services/balances_service.dart';
import 'package:debtor/widgets/user_bar.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

BalancesService _balancesService = BalancesService();
Authenticator _authenticator = Authenticator();

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
        onPressed: () async {
          final currentUser = await _authenticator.loggedInUser.first;
          final amount = await showDialog<Decimal>(
            context: context,
            builder: (ctx) => Container(
                  child: AlertDialog(
                    title: const Center(
                      child: Text('Add payment'),
                    ),
                    content: PaymentForm(currentUser.user, _friend, _balance),
                  ),
                ),
          );

          if (amount != null) {
            await _balancesService.pay(_friend.uid, amount);
            Navigator.pop(context);
          }
        },
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
