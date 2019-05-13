import 'package:decimal/decimal.dart';

class Balance {
  String otherPartyId;
  Decimal amount;

  Balance(this.otherPartyId, this.amount);
}
