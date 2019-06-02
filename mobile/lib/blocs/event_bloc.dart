import 'package:debtor/models/event.dart';
import 'package:debtor/repositories/event_repository.dart';
import 'package:rxdart/rxdart.dart';

class EventBloc {
  final _repository = EventRepository();

  Observable<List<Event>> get events => _repository.events;

  void addEvent(Event event) {
    _repository.addEvent(event);
  }

  void updateEvent(Event event) {
    if (event != null) {
      _repository.updateEvent(event);
    }
  }
}
