import 'package:debtor/authenticator.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/balance_item.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/payment_page.dart';
import 'package:debtor/services/balances_service.dart';
import 'package:debtor/widgets/currency_display.dart';
import 'package:debtor/widgets/exchange_currency_display.dart';
import 'package:debtor/widgets/user_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

BalancesService _balancesService = BalancesService();
Authenticator _authenticator = Authenticator();

class FriendPage extends StatelessWidget {
  final User _friend;
  final Balance _balance;

  const FriendPage(this._friend, this._balance, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.attach_money),
        onPressed: () async {
          final currentUser = await _authenticator.loggedInUser.first;
          await Navigator.push<bool>(
            context,
            MaterialPageRoute<bool>(
              builder: (context) =>
                  PaymentPage(currentUser.user, _friend, _balance),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: UserBar(_friend, _balance),
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

              if (balances.isEmpty) {
                return Center(
                  child: Text('You have no balances with ${_friend.name}'),
                );
              }

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
  static DateFormat formatter = DateFormat('d MMM yyyy');

  final BalanceItem balance;
  const ExpenseTile(this.balance);

  @override
  Widget build(BuildContext context) {
    final amount =
        balance.payer.isCurrentUser ? balance.amount : -balance.amount;

    final exchangedAmount = balance.payer.isCurrentUser
        ? balance.exchangedAmount
        : -balance.exchangedAmount;

    return ListTile(
      leading: Icon(balance.isExpense ? Icons.receipt : Icons.attach_money),
      title: Text(balance.description, style: const TextStyle(fontSize: 18)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(balance.payer.name),
          Text(formatter.format(balance.date))
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CurrencyDisplay(
              amount,
              balance.currency,
            ),
          ),
          Visibility(
            visible: balance.isExchanged,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              child: ExchangeCurrencyDisplay(
                exchangedAmount,
                balance.exchangedCurrency,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
