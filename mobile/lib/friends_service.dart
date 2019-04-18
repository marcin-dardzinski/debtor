import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debtor/models/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:debtor/authenticator.dart';

class FriendsService {
  factory FriendsService() {
    return _instance;
  }
  FriendsService._internal() {
    _friendsState.sink.add([
      User('id', 'Jolene Woodard', 'jolenewoodard@zillacom.com',
          'http://i.pravatar.cc/227'),
      User('id', 'Debora Nicholson', 'deboranicholson@zillacom.com',
          'http://i.pravatar.cc/245'),
      User('id', 'Rogers Molina', 'rogersmolina@zillacom.com',
          'http://i.pravatar.cc/233'),
      User('id', 'Waters Navarro', 'watersnavarro@zillacom.com',
          'http://i.pravatar.cc/242'),
      // User('id', 'Lauri Lyons', 'laurilyons@zillacom.com',
      //     'http://i.pravatar.cc/247'),
      // User('id', 'Conley Welch', 'conleywelch@zillacom.com',
      //     'http://i.pravatar.cc/248'),
      // User('id', 'Lauri Lyons', 'laurilyons@zillacom.com',
      //     'http://i.pravatar.cc/247'),
      // User('id', 'Conley Welch', 'conleywelch@zillacom.com',
      //     'http://i.pravatar.cc/248'),
    ].toList());
  }
  static final FriendsService _instance = FriendsService._internal();

  final _authenticator = Authenticator();
  final _friendsState = BehaviorSubject<List<User>>();
  Stream<List<User>> get friends => _friendsState.stream;

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
        .map((u) => User(u.documentID, u['email'].toString(),
            u['name'].toString(), u['avatar'].toString()))
        .toList();
  }
}
