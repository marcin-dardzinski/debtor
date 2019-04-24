import 'package:debtor/authenticator.dart';
import 'package:debtor/friends_service.dart';
import 'package:debtor/pages/event_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Authenticator authenticator = Authenticator();
FriendsService friends = FriendsService();

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(),
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
}
