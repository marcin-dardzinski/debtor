import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';

class Event {
  final String name;
  final List<User> participants;
  final List<Expense> expenseList;

  Event(this.name, this.expenseList, this.participants);
}