import 'package:debtor/blocs/event_bloc.dart';
import 'package:flutter/material.dart';

class EventBlocProvider extends InheritedWidget {
  EventBlocProvider({Key key, this.child}) : super(key: key);

  final Widget child;
  final EventBloc bloc = EventBloc();

  static EventBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(EventBlocProvider)
            as EventBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(EventBlocProvider oldWidget) {
    return true;
  }
}
