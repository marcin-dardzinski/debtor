import 'package:debtor/models/user.dart';
import 'package:rxdart/rxdart.dart';

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
      User('id', 'Lauri Lyons', 'laurilyons@zillacom.com',
          'http://i.pravatar.cc/247'),
      User('id', 'Conley Welch', 'conleywelch@zillacom.com',
          'http://i.pravatar.cc/248'),
    ].toList());
  }
  static final FriendsService _instance = FriendsService._internal();

  final _friendsState = BehaviorSubject<List<User>>();
  Stream<List<User>> get friends => _friendsState.stream;
}
