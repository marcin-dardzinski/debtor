import 'package:debtor/models/expense.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
class ExpenseForm extends StatefulWidget {
  ExpenseForm({Key key}) : super(key: key);

  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  Widget build(BuildContext context) {
  var expense = Expense.empty();
  

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextFormField(
            decoration: InputDecoration(labelText: 'Name', hintText: 'Expense name'),
            onSaved: (value) => expense.name = value,
          ),
          TextFormField(decoration: InputDecoration(labelText: 'Description'), onSaved: (value) => expense.description = value),
          TextFormField(decoration: InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number, onSaved: (amount) => expense.amount = Decimal.parse(amount)),
          RaisedButton(child: const Text('Submit'), onPressed: () {
            _formKey.currentState.save();
            Navigator.pop(context, expense);
          })
        ],
      ),
    );
  }
}