import 'package:debtor/helpers.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/services/currencies_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

CurrenciesService currenciesService = CurrenciesService();

class ExpenseForm extends StatefulWidget {
  ExpenseForm({Key key, this.availableParticipants}) : super(key: key);
  final List<User> availableParticipants;

  @override
  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Expense expense;
  User _currentPayer;
  User _currentBorrower;
  List<DropdownMenuItem<User>> availableParticipants;
  String _currency;

  @override
  void initState() {
    expense = Expense.empty();
    availableParticipants = _getUsersDropdown();
    _currentPayer = availableParticipants[0].value;
    _currentBorrower = availableParticipants[0].value;
    _currency = 'PLN';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expense = Expense.empty();

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: TextFormField(
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      onSaved: (amount) =>
                          expense.amount = Decimal.parse(amount)),
                ),
                Container(
                  width: 65,
                  margin: const EdgeInsets.only(top: 11), // :(
                  child: DropdownButtonFormField<String>(
                    items: _getCurrenciesDropdown(),
                    value: _currency,
                    onChanged: (value) => setState(() => _currency = value),
                    onSaved: (value) =>
                        setState(() => expense.currency = _currency),
                  ),
                ),
              ],
            ),
            DropdownButtonFormField<User>(
                decoration: InputDecoration(labelText: 'Borrower'),
                items: _getUsersDropdown(),
                value: _currentBorrower,
                onChanged: (value) => setState(() => _currentBorrower = value),
                onSaved: (value) => expense.borrower = _currentBorrower),
            DropdownButtonFormField<User>(
                decoration: InputDecoration(labelText: 'Payer'),
                items: _getUsersDropdown(),
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

  List<DropdownMenuItem<User>> _getUsersDropdown() {
    return widget.availableParticipants
        .map((x) => DropdownMenuItem(
            value: x, child: Text(displayUserNameWithYouIndicator(x))))
        .toList();
  }

  List<DropdownMenuItem<String>> _getCurrenciesDropdown() {
    return currenciesService.allCurrencies
        .map(
          (c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ),
        )
        .toList();
  }
}
