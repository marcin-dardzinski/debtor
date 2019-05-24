import 'package:debtor/authenticator.dart';
import 'package:debtor/forms/payment_form.dart';
import 'package:debtor/helpers.dart';
import 'package:debtor/models/balance_item.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/services/balances_service.dart';
import 'package:debtor/widgets/currency_display.dart';
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
            await _balancesService.pay(_friend.uid, amount, 'PLN');
            Navigator.pop(context);
          }
        },
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: UserBar(
              user: _friend,
              totalBalance: _balance,
            ),
          ),
          StreamBuilder<List<BalanceItem>>(
            stream: _balancesService.balancesWithUser(_friend),
            builder: (ctx, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final balances = snapshot.data;

              return Expanded(
                  child: ListView.builder(
                itemCount: 2 * balances.length,
                itemBuilder: (ctx, idx) =>
                    idx % 2 == 0 ? ExpenseTile(balances[idx ~/ 2]) : Divider(),
              ));
            },
          )
        ],
      ),
    );
  }
}

class ExpenseTile extends StatelessWidget {
  final BalanceItem balance;
  const ExpenseTile(this.balance);

  @override
  Widget build(BuildContext context) {
    final amount =
        balance.payer.isCurrentUser ? balance.amount : -balance.amount;

    return ListTile(
      leading: Icon(balance.isExpense ? Icons.receipt : Icons.attach_money),
      title: Text(balance.description),
      subtitle: Text(balance.payer.name),
      trailing: Container(
        margin: const EdgeInsets.only(right: 8),
        child: CurrencyDisplay(
          balance.amount,
          balance.currency,
        ),
      ),
    );
  }
}
