import 'package:debtor/forms/expense_form/user_selection_dropdown.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import 'package:debtor/services/currencies_service.dart';

CurrencyExchangeService currenciesService = CurrencyExchangeService();

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({Key key, this.availableParticipants}) : super(key: key);
  final List<User> availableParticipants;

  @override
  ExpenseFormState createState() => ExpenseFormState();
}

class ExpenseFormState extends State<ExpenseForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Expense expense;

  @override
  void initState() {
    expense = Expense.empty();
    expense.currency = 'PLN';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: currenciesService.allCuriencies(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Name', hintText: 'Expense name'),
                    onSaved: (value) => expense.name = value,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'The name has to be specified!';
                      }
                    },
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
                              expense.amount = Decimal.parse(amount),
                          validator: (amount) {
                            if (!isFloat(amount)) {
                              return 'Should be a number!';
                            }

                            if (isNull(amount)) {
                              return 'Cannot be empty!';
                            }
                          },
                        ),
                      ),
                      Container(
                        width: 65,
                        margin: const EdgeInsets.only(top: 11), // :(
                        child: DropdownButton<String>(
                            items: snapshot.data
                                .map((c) => new DropdownMenuItem(
                                      value: c,
                                      child: Text(c),
                                    ))
                                .toList(),
                            value: expense.currency,
                            onChanged: (value) =>
                                setState(() => expense.currency = value)),
                      ),
                    ],
                  ),
                  UserSelectionDropdown(
                      label: 'Borrower',
                      users: widget.availableParticipants,
                      selectedUser: expense.borrower,
                      onChanged: (User value) => setState(() {
                            if (value == expense.payer) {
                              expense.payer = expense.borrower;
                            }
                            expense.borrower = value;
                          }),
                      validator: (User value) {
                        if (value == null) {
                          return 'Borrower has to be specified!';
                        }
                      }),
                  UserSelectionDropdown(
                    label: 'Payer',
                    users: widget.availableParticipants,
                    selectedUser: expense.payer,
                    onChanged: (User value) => setState(() {
                          if (value == expense.borrower) {
                            expense.borrower = expense.payer;
                          }
                          expense.payer = value;
                        }),
                    validator: (User value) {
                      if (value == null) {
                        return 'Payer has to be specified!';
                      }
                    },
                  ),
                  RaisedButton(
                      child: const Text('Submit'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          _formKey.currentState.save();
                          Navigator.pop(context, expense);
                        }
                      })
                ],
              ),
            ),
          );
        });
  }
}
