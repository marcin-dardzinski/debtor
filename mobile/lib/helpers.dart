import 'models/user.dart';

String displayUserNameWithYouIndicator(User user) {
  return user.isCurrentUser ? '${user.name} (You)' : user.name;
}
