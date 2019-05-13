import 'package:debtor/blocs/event_bloc.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/pages/event_details_page.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/providers/event_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class EventsPage extends StatefulWidget {
  EventsPage({Key key}) : super(key: key);

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
          onPressed: () {
            Navigator.push(
                    context,
                    MaterialPageRoute<Event>(
                        builder: (ctx) => EventDetailsPage(
                            event: Event('', 'Yayyy', <User>[], <Expense>[]))))
                .then((updatedEvent) {
              if (updatedEvent != null) {
                _bloc.addEvent(updatedEvent);
              }
            });
          }),
    );
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

          return ListView.builder(
            itemCount: snapshot.data.length,
            itemBuilder: (ctx, idx) => _eventToListTile(snapshot.data[idx]),
          );
        });
  }

  ListTile _eventToListTile(Event event) {
    return ListTile(
        title: Text(event.name),
        onTap: () {
          Navigator.push(
                  context,
                  MaterialPageRoute<Event>(
                      builder: (ctx) => EventDetailsPage(event: event)))
              .then((updatedEvent) {
            if (updatedEvent != null) {
              _bloc.updateEvent(updatedEvent);
            }
          });
        });
  }
}
