import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
class Expense {
  final String uid;
  final String name;
  final String description;
  final Decimal amount;
  final User payer;
  final User borrower;

  Expense(this.uid, this.name, this.description, this.amount, this.payer, this.borrower);

}