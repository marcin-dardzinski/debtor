import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';

class Expense {
  String name;
  String description;
  Decimal amount;
  User payer;
  User borrower;
  String currency;

  Expense(this.name, this.description, this.amount, this.payer, this.borrower,
      this.currency);
  Expense.empty();
}
