import 'package:debtor/models/expense.dart';
import 'package:debtor/repositories/expense_repository.dart';
import 'package:rxdart/rxdart.dart';

class ExpenseBloc {
  final _repository = ExpenseRepository();

  Observable<List<Expense>> get expenses => Observable(_repository.expenses);
  
}