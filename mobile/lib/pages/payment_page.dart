import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/models/balance.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/services/balances_service.dart';
import 'package:debtor/services/currencies_service.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

final CurrenciesService currenciesService = CurrenciesService();
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
  String _currency;
  bool currentUserIsPaying;
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final zero = Decimal.fromInt(0);
    final balances = widget.balance.amounts;
    final firstDebt =
        balances.entries.firstWhere((e) => e.value != zero, orElse: () => null);
    if (firstDebt != null) {
      amountController.text = firstDebt.value.abs().toStringAsFixed(2);
      _currency = firstDebt.key;
      currentUserIsPaying = firstDebt.value <= zero;
    } else {
      amountController.text = '00.00';
      _currency = 'PLN';
      currentUserIsPaying = true;
    }
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
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                UserDisplay(widget.currentUser),
                Icon(
                  currentUserIsPaying ? Icons.arrow_forward : Icons.arrow_back,
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
                      decoration: InputDecoration(labelText: 'Amount'),
                      keyboardType: TextInputType.number,
                      controller: amountController,
                    ),
                  ),
                  Container(
                    width: 65,
                    margin: const EdgeInsets.only(top: 11), // :(
                    child: DropdownButtonFormField<String>(
                      items: _getCurrenciesDropdown(),
                      value: _currency,
                      onChanged: (value) => setState(() => _currency = value),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
    var amount = Decimal.parse(amountController.text);

    if (amount != zero) {
      amount = currentUserIsPaying ? amount : -amount;
      await _balancesService.pay(widget.otherUser.uid, amount, _currency);
      Navigator.pop(context, true);
    }
    Navigator.pop(context, false);
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
