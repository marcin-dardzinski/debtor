import 'package:debtor/authenticator.dart';
import 'package:debtor/blocs/event_bloc.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/pages/event_details_page/event_details_page.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/providers/event_bloc_provider.dart';
import 'package:debtor/widgets/event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final Authenticator authenticator = Authenticator();

class EventsPage extends StatefulWidget {
  const EventsPage({Key key}) : super(key: key);

  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  EventBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = EventBlocProvider.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildEventsList(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            final me = await authenticator.loggedInUser.first;
            final updatedEvent = await Navigator.push(
              context,
              MaterialPageRoute<Event>(
                builder: (ctx) => EventDetailsPage(
                      Event('', '', [me.user], <Expense>[], DateTime.now()),
                    ),
              ),
            );
            if (updatedEvent != null) {
              _bloc.addEvent(updatedEvent);
            }
          }),
    );
  }

  Function _updateEventTapFactory(Event event) {
    return () => Navigator.push(context,
            MaterialPageRoute<Event>(builder: (ctx) => EventDetailsPage(event)))
        .then((Event event) => _bloc.updateEvent(event));
  }

  Widget _buildEventsList() {
    return StreamBuilder<List<Event>>(
        stream: _bloc.events,
        builder: (context, AsyncSnapshot<List<Event>> snapshot) {
          if (!snapshot.hasData) {
            return Loader();
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          return EventList(
              events: snapshot.data, onTapFactory: _updateEventTapFactory);
        });
  }
}
