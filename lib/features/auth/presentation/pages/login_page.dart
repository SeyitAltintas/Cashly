import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'signup_page.dart';
import 'user_list_page.dart';
import '../../../../core/services/biometric_service.dart';
import '../state/login_page_state.dart';

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
  late final LoginPageState _loginState;

  UserEntity? get _targetUser => _loginState.targetUser;
  bool get _isLoadingUser => _loginState.isLoadingUser;
  bool get _isGenericLogin => _loginState.isGenericLogin;
  bool get _isBiometricAvailable => _loginState.isBiometricAvailable;

  @override
  void initState() {
    super.initState();
    _loginState = LoginPageState();
    _loginState.addListener(_onStateChanged);

    if (widget.preSelectedUser != null) {
      _loginState.targetUser = widget.preSelectedUser;
      _loginState.isLoadingUser = false;
      _checkBiometricAvailability();
    } else {
      _loadLastUser();
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _loginState.removeListener(_onStateChanged);
    _loginState.dispose();
    super.dispose();
  }

  Future<void> _loadLastUser() async {
    final users = await widget.authController.getAllUsers();
    final lastUserId = await widget.authController.getLastUserId();

    if (mounted) {
      if (users.isNotEmpty) {
        UserEntity? targetUser;
        if (lastUserId != null) {
          final lastUserIndex = users.indexWhere((u) => u.id == lastUserId);
          if (lastUserIndex != -1) {
            targetUser = users[lastUserIndex];
          } else {
            targetUser = users.first;
          }
        } else {
          targetUser = users.first;
        }
        _loginState.setLoginState(targetUser: targetUser, isLoadingUser: false);
      } else {
        _loginState.setLoginState(isGenericLogin: true, isLoadingUser: false);
      }

      await _checkBiometricAvailability();
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      _loginState.isBiometricAvailable = isAvailable;
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
        _loginState.isGenericLogin = true;
      },
      onForgotPassword: _handleForgotPassword,
    );
  }
}
