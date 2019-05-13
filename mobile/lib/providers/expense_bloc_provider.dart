import 'package:debtor/blocs/expense_bloc.dart';
import 'package:flutter/material.dart';

class ExpenseBlocProvider extends InheritedWidget {
  ExpenseBlocProvider({Key key}) : super(key: key);

  final bloc = ExpenseBloc();

  static ExpenseBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(ExpenseBlocProvider)
            as ExpenseBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(ExpenseBlocProvider oldWidget) {
    return true;
  }
}
