import 'package:debtor/authenticator.dart';
import 'package:debtor/blocs/event_bloc.dart';
import 'package:debtor/friends_service.dart';
import 'package:debtor/models/event.dart';
import 'package:debtor/pages/event_form.dart';
import 'package:debtor/pages/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Authenticator authenticator = Authenticator();
FriendsService friends = FriendsService();

class EventsPage extends StatelessWidget {
  final EventBloc _bloc = EventBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Event>>(
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
          }),
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

  Widget _buildEventsList(BuildContext context) {
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
        title: Text(event.name), subtitle: Text(event.participants.join(', ')));
  }
}
