import 'package:cached_network_image/cached_network_image.dart';
import 'package:debtor/blocs/event_detail_bloc.dart';
import 'package:debtor/forms/expense_form.dart';
import 'package:debtor/friends_service.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/loader.dart';
import 'package:flutter/material.dart';

FriendsService friendsService = FriendsService();

class EventDetailsPage extends StatefulWidget {
  final Event _event;
  EventDetailsPage(this._event, {Key key}) : super(key: key);

  @override
  _EventDetailsPageState createState() =>
      _EventDetailsPageState(EventDetailsBloc(_event));
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventDetailsBloc _bloc;

  _EventDetailsPageState(this._bloc);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Event>(
        stream: _bloc.event,
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
              icon: const Icon(
                Icons.check,
              ),
              onPressed: () {
                Navigator.pop(context, event);
              }),
        ]),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(child: _buildParticipantsCard(event.participants)),
              Container(child: _buildExpensesCard(event))
            ],
          ),
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
      leading: const Icon(Icons.add),
      title: const Text('Add participant'),
      onTap: () {
        showDialog<User>(
                context: context,
                builder: (ctx) =>
                    Container(child: _buildFriendsListSelection(participants)))
            .then((u) {
          if (u != null) {
            _bloc.addUser(u);
          }
        });
      },
    );

    return _buildCardGroup(
        header, _buildParticipantsList(participants), footer);
  }

  Widget _buildFriendsListSelection(List<User> participants) {
    return AlertDialog(
        title: const Text('Add friends'),
        content: StreamBuilder<List<User>>(
          stream: friendsService.friends,
          builder: (ctx, snapshot) {
            if (!snapshot.hasData) {
              return Loader();
            }

            final unaddedFriends = snapshot.data;
            unaddedFriends.removeWhere(
                (u) => participants.map((User p) => p.uid).contains(u.uid));
            return Container(
                width: 300,
                height: 300,
                child: ListView.builder(
                  itemCount: unaddedFriends.length,
                  itemBuilder: (ctx, idx) {
                    return ListTile(
                        title: Text(unaddedFriends[idx].name),
                        onTap: () => Navigator.pop(ctx, unaddedFriends[idx]));
                  },
                ));
          },
        ));
  }

  Widget _buildExpensesCard(Event event) {
    final header = ListTile(
        leading: const Icon(Icons.attach_money), title: const Text('Expenses'));
    final footer = ListTile(
      leading: const Icon(Icons.add),
      title: const Text('Add expense'),
      onTap: () {
        showDialog<Expense>(
                context: context,
                builder: (ctx) => Container(
                    child: AlertDialog(
                        title: const Text('Add expense'),
                        content: ExpenseForm(
                            availableParticipants: event.participants))))
            .then((Expense createdExpense) {
          if (createdExpense != null) {
            _bloc.addExpense(createdExpense);
          }
        });
      },
    );

    return _buildCardGroup(header, _buildExpensesList(event.expenses), footer);
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
