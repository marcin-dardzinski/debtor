import 'package:debtor/models/event.dart';
import 'package:debtor/widgets/event_tile.dart';
import 'package:flutter/material.dart';

class EventList extends StatelessWidget {
  const EventList({Key key, this.events, this.onTapFactory}) : super(key: key);
  final List<Event> events;
  final Function(Event) onTapFactory;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: events.length,
        itemBuilder: (ctx, idx) =>
            EventTile(event: events[idx], onTap: onTapFactory(events[idx])));
  }
}
