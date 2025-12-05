import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;
  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthController(this._authRepository);

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> checkAuth() async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String userId, String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _authRepository.loginUser(userId, pin);
      if (user != null) {
        _currentUser = user;
        return true;
      } else {
        _error = "Hatalı PIN veya kullanıcı bulunamadı.";
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String name, String email, String pin) async {
    _setLoading(true);
    _error = null;
    try {
      final newUser = UserEntity(
        id: const Uuid().v4(),
        name: name,
        email: email,
        pin: pin,
        createdAt: DateTime.now(),
      );
      await _authRepository.registerUser(newUser);
      _currentUser = newUser;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<List<UserEntity>> getAllUsers() async {
    return await _authRepository.getAllUsers();
  }

  Future<bool> loginByEmail(String email, String pin) async {
    _setLoading(true);
    _error = null;

    try {
      final users = await _authRepository.getAllUsers();
      final userIndex = users.indexWhere((u) => u.email == email);

      if (userIndex == -1) {
        _error = "Kullanıcı bulunamadı";
        return false;
      }

      final user = users[userIndex];
      if (user.pin == pin) {
        await _authRepository.loginUser(user.id, pin);
        _currentUser = user;
        return true;
      } else {
        _error = "Hatalı PIN";
        return false;
      }
    } catch (e) {
      _error = "Giriş yapılamadı: $e";
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<String?> getLastUserId() {
    return _authRepository.getLastUserId();
  }
}
