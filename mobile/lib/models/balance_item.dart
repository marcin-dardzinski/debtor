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

  BalanceItem(
    this.payer,
    this.recipient,
    this.date,
    this.amount,
    this.currency,
    this.description,
    this.isExpense,
  );
}
