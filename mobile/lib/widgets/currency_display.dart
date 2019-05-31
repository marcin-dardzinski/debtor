import 'package:debtor/helpers.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class CurrencyDisplay extends StatelessWidget {
  final Decimal amount;
  final String currency;
  const CurrencyDisplay(this.amount, this.currency);

  @override
  Widget build(BuildContext context) {
    final prefix = amount < Decimal.fromInt(0) ? '' : ' ';

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: prefix + amount.toStringAsFixed(2),
            style: TextStyle(
              color: getColorForBalance(amount),
            ),
          ),
          TextSpan(text: ' ' + currency),
        ],
      ),
    );
  }
}
