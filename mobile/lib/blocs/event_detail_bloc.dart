import 'package:debtor/models/event.dart';
import 'package:debtor/models/expense.dart';
import 'package:debtor/models/user.dart';
import 'package:debtor/repositories/event_repository.dart';
import 'package:rxdart/rxdart.dart';

class EventDetailsBloc {
  final _repository = EventRepository();
  final _eventDetailsState = BehaviorSubject<Event>();

  Observable<Event> get event => _eventDetailsState.stream;
  final Event selectedEvent;

  EventDetailsBloc(this.selectedEvent) {
    _eventDetailsState.add(selectedEvent);
  }

  void addExpense(Expense expense) {
    if (expense != null) {
      selectedEvent.expenses.add(expense);
      _eventDetailsState.add(selectedEvent);
    }
  }

  void removeExpense(Expense expense) {
    if (expense != null) {
      selectedEvent.expenses.remove(expense);
      _eventDetailsState.add(selectedEvent);
    }
  }

  void addUser(User user) {
    if (user != null) {
      selectedEvent.participants.add(user);
      _eventDetailsState.add(selectedEvent);
    }
  }

  void deleteUser(User user) {
    selectedEvent.participants.remove(user);
    selectedEvent.expenses.removeWhere(
        (Expense expense) => expense.payer == user || expense.borrower == user);
    _eventDetailsState.add(selectedEvent);
  }

  Future updateEvent(Event event) async {
    await _repository.updateEvent(event);
  }
}
