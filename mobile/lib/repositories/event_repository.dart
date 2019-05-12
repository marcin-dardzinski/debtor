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


  Future updateEvent(Event event) async {
    final expenses = event.expenses.map((Expense e) => _expenseToMap(e)).toList();
    await _firestore.collection('events')
              .document(event.uid)
              .updateData( <String, dynamic>{'expenses': expenses});
  }

  Map<String, dynamic> _expenseToMap(Expense e) {
      return <String, dynamic>{
        'name': e.name,
        'description': e.description,
        'amount': e.amount.toInt(),
        'payer': _firestore.collection('users').document(e.payer.uid),
        'borrower': _firestore.collection('users').document(e.borrower.uid)
      };
  }

  Stream<List<Event>> get events {
    final events = _authenticator.loggedInUser.asyncExpand(_fetchUserEvents)
                                              .asyncMap((snapshot) => Future.wait(snapshot.documents.map(convertDocumentToEvent)));

    return Observable(events);
  }

  Stream<Event> getSpecificEvent(Event selectedEvent) {
    final event = _firestore.collection('users').document(selectedEvent.uid).snapshots().asyncMap((document) async => await convertDocumentToEvent(document));

    return Observable(event);
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
    final amount = Decimal.fromInt(expenseMap['amount']);
    final description = expenseMap['description'].toString();
    final name = expenseMap['name'].toString();
    final borrower = eventUsers.firstWhere((User u) => u.uid == expenseMap['borrower'].documentID);
    final payer =  eventUsers.firstWhere((User u) => u.uid == expenseMap['payer'].documentID);

    return Expense(name, description, amount, payer, borrower);
  }
}
