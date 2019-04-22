import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/expense_share.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

class EventForm extends StatefulWidget {
  @override
  EventFormState createState() {
    return EventFormState();
  }
}

class EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final event = Event('Test Event', <Expense>[
    Expense(Decimal.fromInt(20), 'Expense 1', 'blank'),
    Expense(Decimal.fromInt(30), 'Expense 2', 'blank')
  ], <ExpenseShare>[
    ExpenseShare('Person 1', Decimal.fromInt(15)),
    ExpenseShare('Person 2', Decimal.fromInt(25)),
  ]);

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
                child: ListTile(
              leading: const Icon(Icons.event),
              title: TextField(
                decoration: InputDecoration(hintText: 'Event name'),
              ),
            )),
            Expanded(child: Container(child: _buildPayersCard(context))),
            Expanded(child: Container(child: _buildExpensesCard(context))),
          ],
        ));
  }

  Widget _buildCardGroup(
      BuildContext context, Widget header, Widget content, Widget footer) {
    return Card(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[header, content, footer]),
    );
  }

  Widget _buildPayersCard(BuildContext context) {
    final header = ListTile(
        leading: const Icon(Icons.group), title: const Text('Participants'));

    final footer = Container(
        child: ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add payer'),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ));

    final content =
        Expanded(child: Container(child: _buildPayersList(context)));

    return _buildCardGroup(context, header, content, footer);
  }

  Widget _buildPayersList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: event.expenceShareList.length,
      itemBuilder: (BuildContext ctx, int index) {
        return ListTile(
            title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('${event.expenceShareList[index].person}',
                style: TextStyle(fontSize: 14)),
            Text('${event.expenceShareList[index].amount} \$',
                style: TextStyle(fontSize: 14)),
          ],
        ));
      },
    );
  }

  Widget buildExpensesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: event.expenseList.length,
      itemBuilder: (BuildContext ctx, int index) {
        return Dismissible(
          child: ListTile(
              title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text('${event.expenseList[index].name}',
                  style: TextStyle(fontSize: 14)),
              Text('${event.expenseList[index].amount} \$',
                  style: TextStyle(fontSize: 14)),
            ],
          )),
          key: ObjectKey(event.expenseList[index]),
          onDismissed: (direction) {
            var item = event.expenseList.elementAt(index);
            event.expenseList.removeAt(index);
            //To show a snackbar with the UNDO button
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text("Deleted expense"),
                action: SnackBarAction(
                    label: "Undo",
                    onPressed: () {
                      event.expenseList.insert(index, item);
                    })));
          },
        );
      },
    );
  }

  Widget _buildExpensesCard(BuildContext context) {
    final header = ListTile(
        leading: const Icon(Icons.monetization_on),
        title: const Text('Expenses'));

    final footer = Container(
        child: ListTile(
          leading: const Icon(Icons.add),
          title: const Text('Add expense'),
        ),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ));

    final content =
        Expanded(child: Container(child: buildExpensesList(context)));

    return _buildCardGroup(context, header, content, footer);
  }
}
