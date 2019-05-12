import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class ExpenseForm extends StatefulWidget {
  ExpenseForm({Key key, this.availableParticipants}) : super(key: key);
  final List<User> availableParticipants;

  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Expense expense;
  User _currentPayer;
  User _currentBorrower;
  List<DropdownMenuItem<User>> availableParticipants;

  @override
  void initState() {
    expense = Expense.empty();
    availableParticipants = _getDropdownMenuItems();
    _currentPayer = availableParticipants[0].value;
    _currentBorrower = availableParticipants[0].value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var expense = Expense.empty();
    var participants = _getDropdownMenuItems();

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Name', hintText: 'Expense name'),
              onSaved: (value) => expense.name = value,
            ),
            TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) => expense.description = value),
            TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (amount) => expense.amount = Decimal.parse(amount)),
            DropdownButtonFormField<User>(
                items: _getDropdownMenuItems(),
                value: _currentBorrower,
                onChanged: (value) => setState(() => _currentBorrower = value),
                onSaved: (value) => expense.borrower = _currentBorrower),
            DropdownButtonFormField<User>(
                items: _getDropdownMenuItems(),
                value: _currentPayer,
                onChanged: (value) => setState(() => _currentPayer = value),
                onSaved: (value) => expense.payer = _currentPayer),
            RaisedButton(
                child: const Text('Submit'),
                onPressed: () {
                  _formKey.currentState.save();
                  Navigator.pop(context, expense);
                })
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<User>> _getDropdownMenuItems() {
    return widget.availableParticipants
        .map((x) => DropdownMenuItem(value: x, child: Text(x.name)))
        .toList();
  }
}
