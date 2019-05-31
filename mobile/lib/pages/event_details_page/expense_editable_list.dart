import 'package:debtor/models/expense.dart';
import 'package:debtor/pages/event_details_page/editable_list.dart';
import 'package:debtor/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class ExpenseEditableList extends StatelessWidget {
  const ExpenseEditableList({Key key, this.expenses, this.onAdd, this.onDelete})
      : super(key: key);
  final List<Expense> expenses;
  final Function onAdd;
  final Function onDelete;

  Widget _buildExpenseTile(Expense expense) {
    return Dismissible(
      key: Key(expense.hashCode.toString()),
      child: ListTile(
          leading: UserAvatar(avatar: expense.borrower.avatar),
          title: Text(expense.name),
          trailing: UserAvatar(avatar: expense.payer.avatar)),
      onDismissed: (direction) => onDelete(expense),
    );
  }

  @override
  Widget build(BuildContext context) {
    return EditableList(
      header: ListTile(
          leading: const Icon(Icons.attach_money),
          title: const Text('Expenses')),
      content: ListView.builder(
        shrinkWrap: true,
        itemCount: expenses.length,
        itemBuilder: (BuildContext ctx, int index) {
          return _buildExpenseTile(expenses[index]);
        },
      ),
      footer: ListTile(
        leading: const Icon(Icons.add),
        title: const Text('Add expense'),
        onTap: onAdd,
      ),
    );
  }
}
