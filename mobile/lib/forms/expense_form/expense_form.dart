import 'package:debtor/clients/nbp_api_client.dart';
import 'package:debtor/forms/expense_form/currency_selection_dropdown.dart';
import 'package:debtor/forms/expense_form/user_selection_dropdown.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/services/currency_exchange_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

CurrencyExchangeService test = CurrencyExchangeService(NBPApiClient());

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({Key key, this.availableParticipants}) : super(key: key);
  final List<User> availableParticipants;

  @override
  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Expense expense;
  User _currentPayer;
  User _currentBorrower;
  String _currency;

  @override
  void initState() {
    expense = Expense.empty();
    _currency = 'PLN';
    super.initState();
  }

  Future _getAvailableCurrencies() async {
    // final availableCurrencies = await test.getAvailableCurrencies();
    // setState(() {
    //   _availableCurrencies = availableCurrencies;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final expense = Expense.empty();
    _getAvailableCurrencies();

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
                    child: FutureBuilder(
                        future: test.getAvailableCurrencies(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {
                          if (!snapshot.hasData) {
                            return Loader();
                          }

                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          return DropdownButtonFormField<String>(
                              items: snapshot.data
                                  .toList()
                                  .map((c) => DropdownMenuItem(
                                      value: c, child: Text(c)))
                                  .toList(),
                              value: );
                        })),
              ],
            ),
            UserSelectionDropdown(
                label: 'Borrower',
                users: widget.availableParticipants,
                selectedUser: _currentBorrower,
                onChanged: (User value) => setState(() {
                      if (value == _currentPayer) {
                        _currentPayer = _currentBorrower;
                      }
                      _currentBorrower = value;
                    }),
                onSaved: (User value) => expense.borrower = _currentBorrower),
            UserSelectionDropdown(
                label: 'Payer',
                users: widget.availableParticipants,
                selectedUser: _currentPayer,
                onChanged: (User value) => setState(() {
                      if (value == _currentBorrower) {
                        _currentBorrower = _currentPayer;
                      }
                      _currentPayer = value;
                    }),
                onSaved: (User value) => expense.payer = _currentPayer),
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
}
