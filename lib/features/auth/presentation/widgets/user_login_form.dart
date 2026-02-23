import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../state/user_login_form_state.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';

/// Kullanıcı seçili giriş formu widget'ı
/// Belirli bir kullanıcı için PIN ile giriş ekranı
class UserLoginForm extends StatefulWidget {
  final UserEntity targetUser;
  final AuthController authController;
  final bool isBiometricAvailable;
  final VoidCallback onLoginSuccess;
  final VoidCallback onSwitchUser;
  final VoidCallback onSwitchToGenericLogin;
  final VoidCallback onForgotPassword;

  const UserLoginForm({
    super.key,
    required this.targetUser,
    required this.authController,
    required this.isBiometricAvailable,
    required this.onLoginSuccess,
    required this.onSwitchUser,
    required this.onSwitchToGenericLogin,
    required this.onForgotPassword,
  });

  @override
  State<UserLoginForm> createState() => _UserLoginFormState();
}

class _UserLoginFormState extends State<UserLoginForm> {
  final _pinController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  late final UserLoginFormState _formState;

  // Getter'lar
  bool get _isPinVisible => _formState.isPinVisible;
  bool get _isLoading => _formState.isLoading;
  String? get _pinErrorMessage => _formState.pinErrorMessage;

  @override
  void initState() {
    super.initState();
    _formState = UserLoginFormState();
    _formState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _formState.removeListener(_onStateChanged);
    _formState.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleBiometricLogin() async {
    _formState.startLoading();

    try {
      // Biyometrik doğrulama yap
      final authenticated = await _biometricService.authenticate(
        reason: context.l10n.verifyIdentity,
      );

      if (!mounted) return;

      if (authenticated) {
        // Biyometrik başarılı, giriş yap
        final success = await widget.authController.loginWithBiometric(
          widget.targetUser.id,
        );

        if (!mounted) return;

        if (success) {
          widget.onLoginSuccess();
        } else {
          AppSnackBar.error(
            context,
            widget.authController.error ?? context.l10n.biometricLoginFailed,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          context.l10n.biometricAuthFailed(e.toString()),
        );
      }
    } finally {
      if (mounted) {
        _formState.stopLoading();
      }
    }
  }

  Future<void> _handlePinLogin() async {
    // Önceki hata mesajını temizle
    _formState.clearError();

    if (_pinController.text.isEmpty) {
      _formState.setError("Lütfen PIN giriniz");
      return;
    }

    _formState.startPinLogin();

    try {
      final success = await widget.authController.login(
        widget.targetUser.id,
        _pinController.text,
      );

      if (!mounted) return;

      if (success) {
        widget.onLoginSuccess();
      } else {
        _formState.setError(
          widget.authController.error ?? "Hatalı PIN veya kullanıcı bulunamadı",
        );
      }
    } finally {
      if (mounted) {
        _formState.stopLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/image/seffaflogo.png', height: 70),
              const SizedBox(height: 40),

              // Profil Resmi
              _buildProfileAvatar(),
              const SizedBox(height: 20),

              // Hoşgeldiniz Mesajı
              _buildWelcomeMessage(),
              const SizedBox(height: 60),

              // PIN Girişi ve Biyometrik Buton
              _buildPinInputRow(),

              // PIN Hata Mesajı
              if (_pinErrorMessage != null) _buildErrorMessage(),
              const SizedBox(height: 40),

              // Giriş Butonu
              _buildLoginButton(),
              const SizedBox(height: 24),

              // "veya" ayırıcısı
              _buildDivider(),
              const SizedBox(height: 24),

              // Google butonu
              _buildGoogleButton(),
              const SizedBox(height: 24),

              // Başka Hesap / Şifremi Unuttum
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage: widget.targetUser.profileImage != null
          ? ((widget.targetUser.profileImage!.startsWith('lib/') ||
                        widget.targetUser.profileImage!.startsWith('assets/'))
                    ? AssetImage(widget.targetUser.profileImage!)
                    : FileImage(File(widget.targetUser.profileImage!)))
                as ImageProvider
          : null,
      child: widget.targetUser.profileImage == null
          ? Icon(
              Icons.person,
              size: 60,
              color: Theme.of(context).colorScheme.onSurface,
            )
          : null,
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          context.l10n.welcome,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 24,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.targetUser.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(Icons.autorenew_sharp, color: Colors.white),
                tooltip: "Kullanıcı Değiştir",
                onPressed: widget.onSwitchUser,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // PIN Alanı
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextField(
              controller: _pinController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 22,
                letterSpacing: 6,
              ),
              keyboardType: TextInputType.number,
              obscureText: !_isPinVisible,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "● ● ● ●",
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                  letterSpacing: 4,
                  fontSize: 16,
                ),
                counterText: "",
                border: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPinVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  onPressed: () {
                    _formState.togglePinVisibility();
                  },
                ),
              ),
            ),
          ),
        ),

        // Biyometrik Buton
        if (widget.targetUser.biometricEnabled == true &&
            widget.isBiometricAvailable)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Tooltip(
              message: "Parmak izi ile giriş",
              child: InkWell(
                onTap: _isLoading ? null : _handleBiometricLogin,
                borderRadius: BorderRadius.circular(25),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 30,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            _pinErrorMessage!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePinLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                context.l10n.login,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "${context.l10n.orDivider}",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          // Backend bağlantısı yok
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Row(
          children: [
            Text(
              "G",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: Text(
                context.l10n.loginWithGoogle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: widget.onSwitchToGenericLogin,
          child: Text(
            context.l10n.loginWithAnotherAccount,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        TextButton(
          onPressed: widget.onForgotPassword,
          child: Text(
            context.l10n.forgotPassword,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
