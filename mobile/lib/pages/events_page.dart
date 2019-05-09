import 'package:debtor/blocs/event_bloc.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/pages/event_details_page.dart';
import 'package:debtor/pages/event_form.dart';
import 'package:debtor/pages/loader.dart';
import 'package:debtor/providers/event_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


class EventsPage extends StatefulWidget {
  EventsPage({Key key}) : super(key: key);

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
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (ctx) => Scaffold(
                          resizeToAvoidBottomPadding: false,
                          appBar: AppBar(
                            title: const Text("Add event"),
                            actions: <Widget>[
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {},
                              )
                            ],
                          ),
                          backgroundColor: Colors.grey[300],
                          body: EventForm(),
                        )));
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => EventDetailsPage(event: event)
          )
         )
      );
  }
}