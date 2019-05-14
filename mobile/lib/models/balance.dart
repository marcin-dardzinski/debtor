import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';

class Balance {
  String otherUserId;
  Decimal amount;

  Balance(this.otherUserId, this.amount);
}

Balance balanceFromSnapshot(DocumentSnapshot snap) {
  return Balance(
    snap.documentID,
    Decimal.fromInt(snap.data['amount']),
  );
}
