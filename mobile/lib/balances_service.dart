import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/models/payment.dart';
import 'package:decimal/decimal.dart';
import 'package:tuple/tuple.dart';

class BalancesService {
  factory BalancesService() {
    return _instance;
  }
  BalancesService._internal();

  static final BalancesService _instance = BalancesService._internal();
  final Authenticator _authenticator = Authenticator();

  Future pay(String userId, Decimal amount) async {
    final currentUserId = (await _authenticator.loggedInUser.first).user.uid;
    final payerReceipient =
        _getPayerAndReceipient(currentUserId, userId, amount);
    final payer = payerReceipient.item1;
    final receipient = payerReceipient.item2;
    amount = payerReceipient.item3;

    final payment = Payment(payer, receipient, amount, DateTime.now());

    await Firestore.instance.collection('payments').add(_paymentToMap(payment));
  }

  Tuple3<String, String, Decimal> _getPayerAndReceipient(
      String currentUser, String otherUser, Decimal amount) {
    if (amount > Decimal.fromInt(0)) {
      return Tuple3(currentUser, otherUser, amount.abs());
    }
    return Tuple3(otherUser, currentUser, amount.abs());
  }

  Map<String, dynamic> _paymentToMap(Payment p) {
    return <String, dynamic>{
      'payer': Firestore.instance.collection('users').document(p.payer),
      'receipient':
          Firestore.instance.collection('users').document(p.receipient),
      'amount': p.amount.toDouble(),
      'date': p.date
    };
  }
}
