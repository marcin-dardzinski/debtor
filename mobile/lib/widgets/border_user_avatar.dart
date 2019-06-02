import 'package:debtor/widgets/user_avatar.dart';
import 'package:flutter/material.dart';

class BorderUserAvatar extends StatelessWidget {
  const BorderUserAvatar(
      {Key key, this.avatar, this.radius, this.borderColor, this.borderWidth})
      : super(key: key);
  final String avatar;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: UserAvatar(avatar: avatar),
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
    );
  }
}
