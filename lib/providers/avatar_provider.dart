import 'package:flutter/cupertino.dart';

class AvatarProvider with ChangeNotifier {

  String _avatarPath="assets/avatar.png";
  String get avatarPath => _avatarPath;

  void setAvatarPath(String newPath) {
    _avatarPath = newPath;
    notifyListeners();
  }

}

