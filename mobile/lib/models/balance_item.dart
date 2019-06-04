import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';

class BalanceItem {
  final User payer;
  final User recipient;
  final DateTime date;
  final Decimal amount;
  final String description;
  final String currency;
  final bool isExpense;
  final bool isExchanged;
  final String exchangedCurrency;
  final Decimal exchangedAmount;

  BalanceItem(
    this.payer,
    this.recipient,
    this.date,
    this.amount,
    this.currency,
    this.description,
    this.isExpense,
    this.isExchanged,
    this.exchangedCurrency,
    this.exchangedAmount,
  );
}
