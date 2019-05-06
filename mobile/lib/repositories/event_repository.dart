import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:debtor/authenticator.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:rxdart/rxdart.dart';

class EventRepository {
  final _firestore = Firestore.instance;
  final _authenticator = Authenticator();

  Stream<List<Event>> get events {
    final events = _authenticator.loggedInUser.asyncExpand(_fetchUserEvents)
                                              .asyncMap((snapshot) => Future.wait(snapshot.documents.map(convertDocumentToEvent)));

    return Observable(events);
  }

  Stream<QuerySnapshot> _fetchUserEvents(AuthenticationState user) {
    final userDocument = _firestore.collection('users').document(user.user.uid);
    final res = _firestore.collection('events').where('participants', arrayContains: userDocument).snapshots();
    return res;
  }

  Future<Event> convertDocumentToEvent(DocumentSnapshot document) async {
    final eventId = document.documentID;
    final name = document['name'].toString();
    final participantReferences = List<DocumentReference>.from(document['participants']);
    final participants = await Future.wait(participantReferences.map((DocumentReference ref) => _retrieveUser(ref)));
    final expenses = List<dynamic>.from(document['expenses']).map((dynamic expenseMap) => _retrieveExpense(expenseMap, participants)).toList();

    return Event(eventId, name, participants, expenses);
  }

  Future<User> _retrieveUser (DocumentReference participantReference) async {
    return User.fromDocument(await participantReference.get());
  }
  
  Expense _retrieveExpense (dynamic expenseMap, List<User> eventUsers) {
    DocumentReference w;
    const expenseId = "placeholder";
    final amount = Decimal.fromInt(expenseMap['amount']);
    final description = expenseMap['description'].toString();
    final name = expenseMap['name'].toString();
    final borrower = eventUsers.firstWhere((User u) => u.uid == expenseMap['borrower'].documentID);
    final payer =  eventUsers.firstWhere((User u) => u.uid == expenseMap['payer'].documentID);

    return Expense(expenseId, name, description, amount, payer, borrower);
  }
}
