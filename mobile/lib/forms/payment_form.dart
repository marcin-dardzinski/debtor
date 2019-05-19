import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class PaymentForm extends StatefulWidget {
  PaymentForm(this.currentUser, this.otherUser, this.balance, {Key key})
      : super(key: key);
  final User currentUser;
  final User otherUser;
  final Decimal balance;

  @override
  PaymentFormState createState() =>
      PaymentFormState(currentUser, otherUser, balance);
}

class PaymentFormState extends State<PaymentForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User _payer;
  User _receipient;
  Decimal _multiplier;
  Decimal _balance;

  PaymentFormState(User currentUser, User otherUser, Decimal balance) {
    final currentUserIsPaying = balance < Decimal.fromInt(0);

    _payer = currentUserIsPaying ? currentUser : otherUser;
    _receipient = currentUserIsPaying ? otherUser : currentUser;
    _multiplier = Decimal.fromInt(currentUserIsPaying ? 1 : -1);
    _balance = balance;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(_payer.avatar),
                    ),
                    const Icon(Icons.arrow_right),
                    CircleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(_receipient.avatar),
                    )
                  ],
                ),
              ),
              Text(_payer.name),
              const Text('pays'),
              Text(_receipient.name),
              TextFormField(
                  decoration: InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                  initialValue: _balance.abs().toString(),
                  onSaved: (amount) => _balance = Decimal.parse(amount)),
              RaisedButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    _formKey.currentState.save();
                    Navigator.pop(context, _balance * _multiplier);
                  })
            ],
          ),
        ),
      ),
    );
  }
}
