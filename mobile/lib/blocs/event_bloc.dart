import 'package:debtor/models/event.dart';
import 'package:debtor/repositories/event_repository.dart';
import 'package:rxdart/rxdart.dart';

class EventBloc {
  final _repository = EventRepository();

  Observable<List<Event>> get events => _repository.events;
  
  void updateEvent(Event event) {
    _repository.updateEvent(event);
  }
}