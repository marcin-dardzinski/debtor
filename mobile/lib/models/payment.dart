import 'package:decimal/decimal.dart';

class Payment {
  final String payer;
  final String receipient;
  final Decimal amount;
  final DateTime date;

  Payment(this.payer, this.receipient, this.amount, this.date);
}
