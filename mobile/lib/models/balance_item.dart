import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';

class BalanceItem {
  final User payer;
  final User receipient;
  final DateTime date;
  final Decimal amount;
  final String description;
  final bool isExpense;

  BalanceItem(this.payer, this.receipient, this.date, this.amount,
      this.description, this.isExpense);
}
