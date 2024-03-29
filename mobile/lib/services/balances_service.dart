import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/models/balance_item.dart';
import 'package:debtor/models/payment.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

class BalancesService {
  factory BalancesService() {
    return _instance;
  }
  BalancesService._internal();

  static final BalancesService _instance = BalancesService._internal();
  final Authenticator _authenticator = Authenticator();

  Future pay(String userId, Decimal amount, String currency, bool isConverted,
      String toCurrency, Decimal exchangedAmount) async {
    final currentUserId = (await _authenticator.loggedInUser.first).user.uid;
    final payerRecipient = _getPayerAndRecipient(currentUserId, userId, amount);
    final payer = payerRecipient.item1;
    final recipient = payerRecipient.item2;
    amount = payerRecipient.item3;

    final payment = Payment(payer, recipient, amount, DateTime.now(), currency,
        isConverted, toCurrency, exchangedAmount);

    await Firestore.instance.collection('payments').add(_paymentToMap(payment));
  }

  Stream<List<BalanceItem>> balancesWithUser(User user) {
    final expenses = _expensesWithUser(user);
    final payments = _paymentsWithUser(user);

    return Observable.combineLatest2<Iterable<BalanceItem>,
            Iterable<BalanceItem>, List<BalanceItem>>(
        expenses,
        payments,
        (a, b) => [a, b].expand((x) => x).toList()
          ..sort((a, b) => b.date.compareTo(a.date)));
  }

  Stream<Iterable<BalanceItem>> _expensesWithUser(User user) {
    return _authenticator.loggedInUser.asyncExpand((currentUser) {
      final currentUserRef =
          Firestore.instance.collection('users').document(currentUser.user.uid);
      final otherUserRef =
          Firestore.instance.collection('users').document(user.uid);

      return Firestore.instance
          .collection('events')
          .where('participants', arrayContains: currentUserRef)
          .snapshots()
          .map((snaps) {
        return snaps.documents.where((doc) {
          final participants = doc['participants'] as List<dynamic>;
          return participants.contains(otherUserRef);
        }).expand((doc) {
          final expenes = doc['expenses'] as List<dynamic>;
          return expenes.where((dynamic exp) {
            final dynamic payer = exp['payer'];
            final dynamic borrower = exp['borrower'];

            return (payer == otherUserRef || payer == currentUserRef) &&
                (borrower == otherUserRef || borrower == currentUserRef);
          }).map((dynamic exp) {
            final payer =
                exp['payer'] == currentUserRef ? currentUser.user : user;
            final recipient =
                exp['borrower'] == currentUserRef ? currentUser.user : user;
            final amount = Decimal.parse(exp['amount'].toString());
            final date = DateTime.parse(doc['date']);
            final description = exp['name'] as String;
            final currency = exp['currency'] as String;

            return BalanceItem(payer, recipient, date, amount, currency,
                description, true, false, "", Decimal.fromInt(0));
          });
        });
      });
    });
  }

  Stream<Iterable<BalanceItem>> _paymentsWithUser(User user) {
    return _authenticator.loggedInUser.asyncExpand((currentUser) {
      final currentUserRef =
          Firestore.instance.collection('users').document(currentUser.user.uid);
      final otherUserRef =
          Firestore.instance.collection('users').document(user.uid);

      final mine = _mapPayments(_getRawPayments(currentUserRef, otherUserRef),
          currentUser.user, user);
      final other = _mapPayments(_getRawPayments(otherUserRef, currentUserRef),
          user, currentUser.user);

      return Observable.combineLatest2<Iterable<BalanceItem>,
              Iterable<BalanceItem>, Iterable<BalanceItem>>(
          mine, other, (a, b) => [a, b].expand((x) => x));
    });
  }

  Stream<Iterable<BalanceItem>> _mapPayments(
      Stream<QuerySnapshot> query, User payer, User recipient) {
    return query.map((snap) {
      return snap.documents.map((doc) {
        final date = DateTime.parse(doc['date']);
        final amount = Decimal.parse(doc['amount'].toString());
        final currency = doc['currency'] as String;

        if (doc.data.containsKey('isExchanged')) {
          final isExchanged = doc['isExchanged'] as bool;
          final exchangedCurrency = doc['exchangedCurrency'].toString();
          final exchangedAmount = Decimal.parse(doc['exchangedAmount']);
          return BalanceItem(
              payer,
              recipient,
              date,
              amount,
              currency,
              'Payment',
              false,
              isExchanged,
              exchangedCurrency,
              exchangedAmount);
        }

        return BalanceItem(payer, recipient, date, amount, currency, 'Payment',
            false, false, '', Decimal.fromInt(0));
      });
    });
  }

  Stream<QuerySnapshot> _getRawPayments(
      DocumentReference payer, DocumentReference recipient) {
    return Firestore.instance
        .collection('payments')
        .where('payer', isEqualTo: payer)
        .where('recipient', isEqualTo: recipient)
        .snapshots();
  }

  Tuple3<String, String, Decimal> _getPayerAndRecipient(
      String currentUser, String otherUser, Decimal amount) {
    if (amount > Decimal.fromInt(0)) {
      return Tuple3(currentUser, otherUser, amount.abs());
    }
    return Tuple3(otherUser, currentUser, amount.abs());
  }

  Map<String, dynamic> _paymentToMap(Payment p) {
    return <String, dynamic>{
      'payer': Firestore.instance.collection('users').document(p.payer),
      'recipient': Firestore.instance.collection('users').document(p.recipient),
      'amount': p.amount.toDouble(),
      'date': p.date.toIso8601String(),
      'currency': p.currency,
      'isExchanged': p.isExchanched,
      'exchangedCurrency': p.exchangeCurrency,
      'exchangedAmount': p.exchangeAmount.toString(),
    };
  }
}
