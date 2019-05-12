import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseRepository {
  final _firestore = Firestore.instance;
  final _authenticator = Authenticator();

  Stream<List<Expense>> get expenses {
    final expensesToPay = _authenticator.loggedInUser.asyncExpand((user) {
      return _firestore
          .collection('expenses')
          .where('borrower',
              isEqualTo: _firestore.collection('users').document(user.user.uid))
          .snapshots();
    }).asyncMap(
        (snapshot) => Future.wait(snapshot.documents.map(_fetchExpense)));

    final expensesToCollect = _authenticator.loggedInUser.asyncExpand((user) {
      return _firestore
          .collection('expenses')
          .where('payer',
              isEqualTo: _firestore.collection('users').document(user.user.uid))
          .snapshots();
    }).asyncMap(
        (snapshot) => Future.wait(snapshot.documents.map(_fetchExpense)));

    return Observable.combineLatest2(expensesToPay, expensesToCollect,
        (List<Expense> a, List<Expense> b) => [a, b].expand((x) => x).toList());
  }

  Future<Expense> _fetchExpense(DocumentSnapshot document) async {
    final name = document['name'].toString();
    final description = document['description'].toString();
    final amount = Decimal.fromInt(document['amount']);
    final payer = User.fromDocument(await document['payer'].get());
    final borrower = User.fromDocument(await document['payer'].get());
    return Expense(name, description, amount, payer, borrower);
  }
}
