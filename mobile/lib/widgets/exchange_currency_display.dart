import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class ExchangeCurrencyDisplay extends StatelessWidget {
  final Decimal amount;
  final String currency;
  const ExchangeCurrencyDisplay(this.amount, this.currency);

  @override
  Widget build(BuildContext context) {
    final prefix = amount < Decimal.fromInt(0) ? '' : ' ';

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          const TextSpan(text: '('),
          TextSpan(
            text: prefix + amount.toStringAsFixed(2),
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          TextSpan(text: ' ' + currency + ')'),
        ],
      ),
    );
  }
}
