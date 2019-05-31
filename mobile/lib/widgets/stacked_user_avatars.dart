import 'package:debtor/models/user.dart';
import 'package:debtor/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class StackedUserAvatars extends StatelessWidget {
  const StackedUserAvatars(
      {Key key, this.users, this.avatarSpacing, this.avatarRadius})
      : super(key: key);
  final List<User> users;
  final double avatarSpacing;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2 * avatarRadius,
      width: 2 * users.length * avatarRadius,
      child: Stack(
          children: users
              .asMap()
              .map((int index, User user) => MapEntry(
                  index,
                  Positioned(
                      left: 2 * index * avatarRadius,
                      child: UserAvatar(
                          avatar: user.avatar, radius: avatarRadius))))
              .values
              .toList()),
    );
  }
}
