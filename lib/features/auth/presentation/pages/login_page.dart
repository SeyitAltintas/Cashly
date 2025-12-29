import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'signup_page.dart';
import 'user_list_page.dart';
import '../../../../services/biometric_service.dart';

// Modüler widget'lar
import '../widgets/generic_login_form.dart';
import '../widgets/user_login_form.dart';
import '../widgets/forgot_password_helper.dart';

/// Login sayfası ana widget'ı
/// Kullanıcı durumuna göre GenericLoginForm veya UserLoginForm gösterir
class LoginPage extends StatefulWidget {
  final AuthController authController;
  final UserEntity? preSelectedUser;

  const LoginPage({
    super.key,
    required this.authController,
    this.preSelectedUser,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final BiometricService _biometricService = BiometricService();

  UserEntity? _targetUser;
  bool _isLoadingUser = true;
  bool _isGenericLogin = false;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedUser != null) {
      _targetUser = widget.preSelectedUser;
      _isLoadingUser = false;
      _checkBiometricAvailability();
    } else {
      _loadLastUser();
    }
  }

  Future<void> _loadLastUser() async {
    final users = await widget.authController.getAllUsers();
    final lastUserId = await widget.authController.getLastUserId();

    if (mounted) {
      setState(() {
        if (users.isNotEmpty) {
          if (lastUserId != null) {
            final lastUserIndex = users.indexWhere((u) => u.id == lastUserId);
            if (lastUserIndex != -1) {
              _targetUser = users[lastUserIndex];
            } else {
              _targetUser = users.first;
            }
          } else {
            _targetUser = users.first;
          }
        } else {
          _isGenericLogin = true;
        }
        _isLoadingUser = false;
      });

      await _checkBiometricAvailability();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
      });
    }
  }

  void _handleLoginSuccess() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => AnaSayfa(authController: widget.authController),
      ),
    );
  }

  void _handleSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignUpPage(authController: widget.authController),
      ),
    );
  }

  void _handleSwitchUser() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserListPage(authController: widget.authController),
      ),
    );
  }

  void _handleForgotPassword() {
    ForgotPasswordHelper(
      authController: widget.authController,
      context: context,
    ).showForgotPasswordSheet();
  }

  @override
  Widget build(BuildContext context) {
    // Yükleme durumu
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Generic login (kullanıcı seçilmemiş veya yeni kullanıcı)
    if (_isGenericLogin || _targetUser == null) {
      return GenericLoginForm(
        authController: widget.authController,
        onLoginSuccess: _handleLoginSuccess,
        onSignUp: _handleSignUp,
        onForgotPassword: _handleForgotPassword,
      );
    }

    // Kullanıcı seçili login
    return UserLoginForm(
      targetUser: _targetUser!,
      authController: widget.authController,
      isBiometricAvailable: _isBiometricAvailable,
      onLoginSuccess: _handleLoginSuccess,
      onSwitchUser: _handleSwitchUser,
      onSwitchToGenericLogin: () {
        setState(() {
          _isGenericLogin = true;
        });
      },
      onForgotPassword: _handleForgotPassword,
    );
  }
}
