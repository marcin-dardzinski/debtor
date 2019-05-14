import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';

class Event {
  final String uid;
  final String name;
  final List<User> participants;
  final List<Expense> expenses;
  final DateTime date;

  Event(this.uid, this.name, this.participants, this.expenses, this.date);
}
