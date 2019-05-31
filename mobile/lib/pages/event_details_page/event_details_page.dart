import 'package:debtor/blocs/event_detail_bloc.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/pages/event_details_page/expenses_card.dart';
import 'package:debtor/pages/event_details_page/participants_card.dart';
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
              ParticipantsCard(
                event: event,
                onAdd: _bloc.addUser,
                onDelete: _bloc.deleteUser,
              ),
              ExpensesCard(
                event: event,
                onAdd: _bloc.addExpense,
                onDelete: _bloc.removeExpense,
              )
            ],
          ),
        ));
  }
}
