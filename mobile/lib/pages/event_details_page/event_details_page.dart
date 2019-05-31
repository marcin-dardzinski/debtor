import 'package:debtor/blocs/event_detail_bloc.dart';
import 'package:debtor/forms/expense_form.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/event_details_page/user_editable_list.dart';
import 'package:debtor/pages/event_details_page/user_selection_list.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/services/friends_service.dart';
import 'package:flutter/material.dart';

FriendsService friendsService = FriendsService();

class EventDetailsPage extends StatefulWidget {
  final Event _event;
  const EventDetailsPage(this._event, {Key key}) : super(key: key);

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState(_event);
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  EventDetailsBloc _bloc;
  TextEditingController eventNameController;
  _EventDetailsPageState(Event event) {
    _bloc = EventDetailsBloc(event);
    eventNameController = TextEditingController(text: event.name);
  }

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
                event.name = eventNameController.text;
                Navigator.pop(context, event);
              }),
        ]),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ListTile(
                  title: TextField(
                      decoration: InputDecoration(labelText: 'Event name'),
                      controller: eventNameController)),
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
    final onTap = () {
      showDialog<List<User>>(
              context: context,
              builder: (ctx) =>
                  Container(child: _buildFriendsListSelection(participants)))
          .then((u) {
        u.forEach((user) => _bloc.addUser(user));
      });
    };

    final onDelete = (User user) {
      _bloc.deleteUser(user);
    };

    return UserEditableList(
        users: participants, onAdd: onTap, onDelete: onDelete);
  }

  Widget _buildFriendsListSelection(List<User> participants) {
    return StreamBuilder<List<User>>(
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
            child: UserSelectionList(
              users: unaddedFriends,
              isSelected: unaddedFriends.map<bool>((User u) => false).toList(),
              onSubmit: (List<User> users) =>
                  users.forEach((User u) => _bloc.addUser(u)),
            ));
      },
    );
  }

  Widget _buildExpensesCard(Event event) {
    final header = ListTile(
        leading: const Icon(Icons.attach_money), title: const Text('Expenses'));
    final footer = ListTile(
      leading: const Icon(Icons.add),
      title: const Text('Add expense'),
      onTap: () async {
        final createdExpense = await showDialog<Expense>(
            context: context,
            builder: (ctx) => Container(
                child: AlertDialog(
                    title: const Text('Add expense'),
                    content: ExpenseForm(
                        availableParticipants: event.participants))));
        if (createdExpense != null) {
          _bloc.addExpense(createdExpense);
        }
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

  Widget _buildExpenseTile(Expense expense) {
    return ListTile(title: Text(expense.name));
  }
}
