import 'package:debtor/blocs/expense_bloc.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/pages/loader.dart';
import 'package:flutter/material.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key key}) : super(key: key);

  @override
  _ExpensesPageState createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final ExpenseBloc _bloc = ExpenseBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: _bloc.expenses,
      builder: (context, AsyncSnapshot<List<Expense>> snapshot) {
        if (!snapshot.hasData) {
          return Loader();
        }

        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (ctx, idx) {
            return ListTile(
                title: Text(snapshot.data[idx].name),
                subtitle: Text(snapshot.data[idx].payer.name.toString()));
          },
        );
      },
    );
  }
}
