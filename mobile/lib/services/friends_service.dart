import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/authenticator.dart';
import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

class FriendsService {
  factory FriendsService() {
    return _instance;
  }
  FriendsService._internal();

  static final FriendsService _instance = FriendsService._internal();
  final _authenticator = Authenticator();

  Stream<List<User>> get friends =>
      _authenticator.loggedInUser.asyncExpand((user) {
        return Firestore.instance
            .collection('users')
            .where('friends',
                arrayContains: Firestore.instance
                    .collection('users')
                    .document(user.user.uid))
            .orderBy('email')
            .snapshots();
      }).map((snap) => snap.documents.map(_toUser).toList());

  Future<void> addFriend(User user) {
    return CloudFunctions.instance.call(
      functionName: 'addFriend',
      parameters: <String, dynamic>{
        'friend': user.uid,
      },
    );
  }

  Stream<Balance> get myTotalBalance => myBalances.map((balances) {
        final total = <String, Decimal>{};
        for (var balance in balances) {
          balance.amounts.forEach((currency, amount) {
            total.update(currency, (current) => current + amount,
                ifAbsent: () => amount);
          });
        }
        return Balance('', total);
      });

  Stream<List<Balance>> get myBalances =>
      _authenticator.loggedInUser.asyncExpand((user) {
        return Firestore.instance
            .collection('users')
            .document(user.user.uid)
            .collection('balances')
            .snapshots();
      }).map((snap) => snap.documents.map(balanceFromSnapshot).toList());

  Future<List<User>> searchFriends(String email) async {
    if (email.isEmpty) {
      return <User>[];
    }

    final currentUser = (await _authenticator.loggedInUser.first).user;

    final emailLow = email;
    final last = email.codeUnitAt(email.length - 1) + 1;
    final emailHigh =
        email.substring(0, email.length - 1) + String.fromCharCode(last);

    final results = await Firestore.instance
        .collection('users')
        .where(
          'email',
          isLessThan: emailHigh,
          isGreaterThanOrEqualTo: emailLow,
        )
        .getDocuments();

    return results.documents
        .where((u) => u.documentID != currentUser.uid)
        .map(_toUser)
        .toList();
  }

  User _toUser(DocumentSnapshot u) {
    return User(u.documentID, u['email'].toString(), u['name'].toString(),
        u['avatar'].toString(), false);
  }
}
