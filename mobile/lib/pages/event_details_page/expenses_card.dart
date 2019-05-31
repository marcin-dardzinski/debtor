import 'package:debtor/forms/expense_form.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/pages/event_details_page/expense_editable_list.dart';
import 'package:flutter/material.dart';

class ExpensesCard extends StatelessWidget {
  const ExpensesCard({Key key, this.onAdd, this.event, this.onDelete})
      : super(key: key);
  final Function onAdd;
  final Function onDelete;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return ExpenseEditableList(
        expenses: event.expenses,
        onAdd: () => showDialog<Expense>(
                context: context,
                builder: (ctx) => Container(
                    child: AlertDialog(
                        title: const Text('Add expense'),
                        content: ExpenseForm(
                            availableParticipants: event.participants))))
            .then<Expense>((Expense e) => onAdd(e)),
        onDelete: onDelete);
  }
}
