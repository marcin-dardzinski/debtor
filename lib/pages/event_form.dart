import 'package:debtor/models/event.dart';
import 'package:flutter/material.dart';

class EventForm extends StatefulWidget {
  @override
  EventFormState createState() {
    return EventFormState();
  }
}

class EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  final event = Event();

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
                decoration: InputDecoration(
                  hintText: 'Event name'
                ),
            ),
          )
          ),
          Expanded(child: Container(child: _buildPayersCard(context))),
          Expanded(child: Container(child: _buildPayersCard(context))),
        ],
      )
    );
  }

  Widget _buildPayersCard(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.group),
            title: Text('Payers')
          ),
          Expanded(
            child: Container(
              child: buildPayersList(context)
              )
          ),
          Container(
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Add payer'),
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            )
          )
        ],
      ),
    );
  }

  Widget buildPayersList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (BuildContext ctx, int index) {
        return ListTile(
          title: Text(
            'Payer ${index.toString()}',
            style: TextStyle(fontSize: 14))
        );
      },
    );
  }
}