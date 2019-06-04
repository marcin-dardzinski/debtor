import 'package:decimal/decimal.dart';

class Payment {
  final String payer;
  final String recipient;
  final Decimal amount;
  final DateTime date;
  final String currency;
  final bool isExchanched;
  final String exchangeCurrency;
  final Decimal exchangeAmount;

  Payment(this.payer, this.recipient, this.amount, this.date, this.currency,
      this.isExchanched, this.exchangeCurrency, this.exchangeAmount);
}
