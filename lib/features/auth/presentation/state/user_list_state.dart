import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

/// User list sayfası için ChangeNotifier state yöneticisi
class UserListState extends ChangeNotifier {
  List<UserEntity> _users = [];
  List<UserEntity> get users => _users;
  set users(List<UserEntity> value) {
    _users = value;
    notifyListeners();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setUsersLoaded(List<UserEntity> users) {
    _users = users;
    _isLoading = false;
    notifyListeners();
  }
}
