import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/widgets/currency_display.dart';
import 'package:flutter/material.dart';

class UserBar extends StatelessWidget {
  final User user;
  final Balance totalBalance;
  const UserBar(this.user, this.totalBalance, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final balanceView = [
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
    ];

    totalBalance.amounts.forEach((currency, amount) {
      balanceView.add(CurrencyDisplay(amount, currency));
    });

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
              children: balanceView,
            ),
          ),
          // Container(
          //   margin: const EdgeInsets.only(right: 16),
          //   child: Text(
          //     totalBalance.toStringAsFixed(2),
          //     style: TextStyle(
          //       fontSize: 18,
          //       fontWeight: FontWeight.bold,
          //       color: getColorForBalance(totalBalance),
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
