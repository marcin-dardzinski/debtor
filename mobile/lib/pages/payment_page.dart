import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/services/balances_service.dart';
import 'package:debtor/services/currencies_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final CurrencyExchangeService currenciesService = CurrencyExchangeService();
final BalancesService _balancesService = BalancesService();

class PaymentPage extends StatefulWidget {
  final User currentUser;
  final User otherUser;
  final Balance balance;

  const PaymentPage(this.currentUser, this.otherUser, this.balance);

  @override
  State<StatefulWidget> createState() => PaymentPageState();
}

class PaymentPageState extends State<PaymentPage> {
  String _fromCurrency;
  String _toCurrency;
  bool isConverted;
  bool currentUserIsPaying;
  final TextEditingController fromAmountController = TextEditingController();
  final TextEditingController toAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final zero = Decimal.fromInt(0);
    final balances = widget.balance.amounts;
    final firstDebt =
        balances.entries.firstWhere((e) => e.value != zero, orElse: () => null);
    if (firstDebt != null) {
      fromAmountController.text = firstDebt.value.abs().toStringAsFixed(2);
      _fromCurrency = firstDebt.key;
      currentUserIsPaying = firstDebt.value <= zero;
    } else {
      fromAmountController.text = '00.00';
      _fromCurrency = 'PLN';
      currentUserIsPaying = true;
    }

    isConverted = false;
    toAmountController.text = '00.00';
    _toCurrency = 'PLN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add payment'),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () => _savePayment(context),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: currenciesService.allCuriencies(),
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return Container(
                margin: const EdgeInsets.all(16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          UserDisplay(widget.currentUser),
                          Icon(
                            currentUserIsPaying
                                ? Icons.arrow_forward
                                : Icons.arrow_back,
                            size: 40,
                          ),
                          UserDisplay(widget.otherUser)
                        ],
                      ),
                      _radioButton('You paid', true),
                      _radioButton('They paid', false),
                      Container(
                          margin: const EdgeInsets.symmetric(horizontal: 100),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: fromAmountController,
                                    onEditingComplete: () async {
                                      var currentValue = Decimal.parse(
                                          fromAmountController.text);
                                      currentValue = await currenciesService
                                          .exchangeCurrencie(currentValue,
                                              _fromCurrency, _toCurrency);
                                      setState(() {
                                        toAmountController.text = currentValue
                                            .abs()
                                            .toStringAsFixed(2);
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  width: 65,
                                  child: DropdownButtonFormField<String>(
                                    items: snapshot.data
                                        .map((String currency) =>
                                            DropdownMenuItem(
                                                value: currency,
                                                child: Text(currency)))
                                        .toList(),
                                    value: _fromCurrency,
                                    onChanged: (value) async {
                                      var currentValue = Decimal.parse(
                                          fromAmountController.text);
                                      currentValue = await currenciesService
                                          .exchangeCurrencie(
                                              currentValue, value, _toCurrency);
                                      setState(() {
                                        toAmountController.text = currentValue
                                            .abs()
                                            .toStringAsFixed(2);
                                        _fromCurrency = value;
                                      });
                                    },
                                  ),
                                )
                              ])),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                                child: CheckboxListTile(
                              title: const Text('Pay in other currency'),
                              value: isConverted,
                              onChanged: (bool value) {
                                setState(() {
                                  isConverted = value;
                                });
                              },
                            ))
                          ],
                        ),
                      ),
                      Visibility(
                        visible: isConverted,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(toAmountController.text),
                            Container(
                              width: 65,
                              child: DropdownButtonFormField<String>(
                                items: snapshot.data
                                    .map((String currency) => DropdownMenuItem(
                                        value: currency, child: Text(currency)))
                                    .toList(),
                                value: _toCurrency,
                                onChanged: (value) async {
                                  var currentValue =
                                      Decimal.parse(fromAmountController.text);
                                  currentValue =
                                      await currenciesService.exchangeCurrencie(
                                          currentValue, _fromCurrency, value);
                                  setState(() {
                                    _toCurrency = value;
                                    toAmountController.text =
                                        currentValue.abs().toStringAsFixed(2);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
              );
            },
          ),
        ));
  }

  Widget _radioButton(String text, bool value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio(
          groupValue: currentUserIsPaying,
          value: value,
          onChanged: _payingUserChanged,
        ),
        Text(text),
      ],
    );
  }

  void _payingUserChanged(bool currentUserIsPaying) {
    setState(() {
      this.currentUserIsPaying = currentUserIsPaying;
    });
  }

  Future _savePayment(BuildContext context) async {
    final zero = Decimal.fromInt(0);
    var amount = Decimal.parse(fromAmountController.text);

    if (amount != zero) {
      amount = currentUserIsPaying ? amount : -amount;
      await _balancesService.pay(widget.otherUser.uid, amount, _fromCurrency);
      Navigator.pop(context, true);
    }
    Navigator.pop(context, false);
  }
}

class UserDisplay extends StatelessWidget {
  final User user;
  const UserDisplay(this.user);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(user.avatar),
          radius: 40,
        ),
        Container(
          margin: const EdgeInsets.only(top: 24),
          child: Text(user.name),
        ),
      ],
    );
  }
}
