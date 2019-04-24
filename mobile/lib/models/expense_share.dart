import 'package:decimal/decimal.dart';

class ExpenseShare {
  final String person; //will be replaced with appropriate model corresponding to a person
  final Decimal amount;

  ExpenseShare(this.person, this.amount);
}