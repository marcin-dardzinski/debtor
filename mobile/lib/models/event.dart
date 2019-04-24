import 'package:debtor/models/expense.dart';
import 'package:debtor/models/expense_share.dart';

class Event {
  final String name;
  final List<Expense> expenseList;
  final List<ExpenseShare> expenceShareList;

  Event(this.name, this.expenseList, this.expenceShareList);
}