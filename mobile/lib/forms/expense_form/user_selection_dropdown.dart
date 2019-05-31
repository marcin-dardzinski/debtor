import 'package:debtor/helpers.dart';
import 'package:debtor/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserSelectionDropdown extends StatelessWidget {
  const UserSelectionDropdown(
      {Key key,
      this.users,
      this.selectedUser,
      this.onChanged,
      this.onSaved,
      this.label})
      : super(key: key);
  final List<User> users;
  final User selectedUser;
  final Function onChanged;
  final Function onSaved;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
        decoration: InputDecoration(labelText: label),
        items: users
            .map((User u) => DropdownMenuItem(
                value: u, child: Text(displayUserNameWithYouIndicator(u))))
            .toList(),
        value: selectedUser,
        onChanged: onChanged,
        onSaved: onSaved);
  }
}
