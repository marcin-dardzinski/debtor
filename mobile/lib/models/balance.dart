import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decimal/decimal.dart';

class Balance {
  String otherUserId;
  Map<String, Decimal> amounts;

  Balance(this.otherUserId, this.amounts);
}

Balance balanceFromSnapshot(DocumentSnapshot snap) {
  // final amountsRaw =
  //      as Map<String, dynamic> ?? Map<String, dynamic>();
  final amounts = (snap['amount'] as Map)
      .map<String, Decimal>((dynamic k, dynamic v) => MapEntry(k, Decimal.parse(v.toString())));

  return Balance(snap.documentID, amounts);
}
