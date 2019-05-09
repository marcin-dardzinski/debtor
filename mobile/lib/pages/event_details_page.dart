import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/blocs/event_detail_bloc.dart';
import 'package:debtor/forms/expense_form.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/providers/event_bloc_provider.dart';
import 'package:flutter/material.dart';

class EventDetailsPage extends StatefulWidget {
  EventDetailsBloc bloc;
  final Event event;
  EventDetailsPage({Key key, this.event}) : super(key: key) {
    bloc = EventDetailsBloc(event);
  }

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
        stream: widget.bloc.event,
        builder: (context, AsyncSnapshot<Event> snapshot) {
          if (!snapshot.hasData) {
            return Loader();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          return _createDetailsPage(snapshot.data);
        });
  }

  Widget _createDetailsPage(Event event) {
    return Scaffold(
        appBar: AppBar(title: Text(event.name), actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.check,
              ),
              onPressed: () {
                widget.bloc.updateEvent(event);
                //Navigator.pop(context);
           }),
        ]),
        body: Column(
          children: <Widget>[
            Container(child: _buildParticipantsCard(event.participants)),
            Container(child: _buildExpensesCard(event.expenses))
          ],
        ));
  }

  Widget _buildCardGroup(Widget header, Widget content, Widget footer) {
    return Card(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          header,
          content,
          Container(
              child: footer, decoration: BoxDecoration(color: Colors.grey[200]))
        ]));
  }

  Widget _buildParticipantsCard(List<User> participants) {
    final header = ListTile(
        leading: const Icon(Icons.group), title: const Text('Participants'));
    final footer = ListTile(
        leading: const Icon(Icons.add), title: const Text('Add participant'));

    return _buildCardGroup(
        header, _buildParticipantsList(participants), footer);
  }

  Widget _buildExpensesCard(List<Expense> expenses) {
    final header = ListTile(
        leading: const Icon(Icons.attach_money), title: const Text('Expenses'));
    final footer = ListTile(
        leading: const Icon(Icons.add), title: const Text('Add expense'), onTap: () {
          showDialog<Expense>(
            context: context,
            builder: (ctx) => Container(child: AlertDialog(
              title: Text("Add expense"),
              content: ExpenseForm()
            )
          )).then((Expense createdExpense) => widget.bloc.addExpense(createdExpense));
        },);

    return _buildCardGroup(header, _buildExpensesList(expenses), footer);
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: expenses.length,
        itemBuilder: (BuildContext ctx, int index) {
          return _buildExpenseTile(expenses[index]);
        });
  }

  Widget _buildParticipantsList(List<User> participants) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: participants.length,
        itemBuilder: (BuildContext ctx, int index) {
          return _buildParticipantTile(participants[index]);
        });
  }

  Widget _buildParticipantTile(User user) {
    return ListTile(
        leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(user.avatar)),
        title: Text(user.name));
  }

  Widget _buildExpenseTile(Expense expense) {
    return ListTile(title: Text(expense.name));
  }
}
