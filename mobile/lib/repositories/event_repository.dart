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

  Future addEvent(Event event) async {
    final expenses =
        event.expenses.map((Expense e) => _expenseToMap(e)).toList();
    final friends = event.participants
        .map((User u) => _firestore.collection('users').document(u.uid))
        .toList();
    await _firestore.collection('events').add(<String, dynamic>{
      'name': event.name,
      'expenses': expenses,
      'participants': friends,
      'date': event.date.toIso8601String()
    });
  }

  Future updateEvent(Event event) async {
    final expenses =
        event.expenses.map((Expense e) => _expenseToMap(e)).toList();
    final friends = event.participants
        .map((User u) => _firestore.collection('users').document(u.uid))
        .toList();
    await _firestore.collection('events').document(event.uid).updateData(
        <String, dynamic>{'expenses': expenses, 'participants': friends, 'name': event.name});
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
    final events = _authenticator.loggedInUser
        .asyncExpand(_fetchUserEvents)
        .asyncMap((snapshot) =>
            Future.wait(snapshot.documents.map(convertDocumentToEvent)));

    return Observable(events);
  }

  Stream<Event> getSpecificEvent(Event selectedEvent) {
    final event = _firestore
        .collection('users')
        .document(selectedEvent.uid)
        .snapshots()
        .asyncMap((document) async => await convertDocumentToEvent(document));

    return Observable(event);
  }

  Stream<QuerySnapshot> _fetchUserEvents(AuthenticationState user) {
    final userDocument = _firestore.collection('users').document(user.user.uid);
    final res = _firestore
        .collection('events')
        .where('participants', arrayContains: userDocument)
        .orderBy('date', descending: true)
        .snapshots();
    return res;
  }

  Future<Event> convertDocumentToEvent(DocumentSnapshot document) async {
    final eventId = document.documentID;
    final name = document['name'].toString();
    final participantReferences =
        List<DocumentReference>.from(document['participants']);
    final participants = await Future.wait(participantReferences
        .map((DocumentReference ref) => _retrieveUser(ref)));
    final expenses = List<dynamic>.from(document['expenses'])
        .map((dynamic expenseMap) => _retrieveExpense(expenseMap, participants))
        .toList();

    final date = DateTime.parse(document['date']);
    return Event(eventId, name, List<User>.from(participants), expenses, date);
  }

  Future<User> _retrieveUser(DocumentReference participantReference) async {
    final me = await _authenticator.loggedInUser.first;
    return User.fromDocument(await participantReference.get(), me.user.uid);
  }

  Expense _retrieveExpense(dynamic expenseMap, List<User> eventUsers) {
    final amount = Decimal.fromInt(expenseMap['amount']);
    final description = expenseMap['description'].toString();
    final name = expenseMap['name'].toString();
    final borrower = eventUsers
        .firstWhere((User u) => u.uid == expenseMap['borrower'].documentID);
    final payer = eventUsers
        .firstWhere((User u) => u.uid == expenseMap['payer'].documentID);

    return Expense(name, description, amount, payer, borrower);
  }
}
