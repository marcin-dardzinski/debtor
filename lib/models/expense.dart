import 'package:decimal/decimal.dart';
class Expense {
  final Decimal amount;
  final String name;
  final String description;

  Expense(this.amount, this.name, this.description);
}