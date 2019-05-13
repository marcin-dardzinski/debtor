import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

import 'models/user.dart';

String displayUserNameWithYouIndicator(User user) {
  return user.isCurrentUser ? '${user.name} (You)' : user.name;
}

Color getColorForBalance(Decimal balance) {
  return balance > Decimal.fromInt(0)
      ? Colors.greenAccent
      : balance < Decimal.fromInt(0) ? Colors.redAccent : Colors.black;
}
