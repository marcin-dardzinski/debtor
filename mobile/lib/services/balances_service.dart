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
            final receipient =
                exp['borrower'] == currentUserRef ? currentUser.user : user;
            final amount = Decimal.parse(exp['amount'].toString());
            final date = DateTime.parse(doc['date']);
            final description = exp['name'] as String;

            return BalanceItem(
                payer, receipient, date, amount, description, true);
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
      Stream<QuerySnapshot> query, User payer, User receipient) {
    return query.map((snap) {
      return snap.documents.map((doc) {
        final date = DateTime.parse(doc['date']);
        final amount = Decimal.parse(doc['amount'].toString());

        return BalanceItem(payer, receipient, date, amount, 'Payment', false);
      });
    });
  }

  Stream<QuerySnapshot> _getRawPayments(
      DocumentReference payer, DocumentReference receipient) {
    return Firestore.instance
        .collection('payments')
        .where('payer', isEqualTo: payer)
        .where('receipient', isEqualTo: receipient)
        .snapshots();
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
      'date': p.date.toIso8601String()
    };
  }
}
