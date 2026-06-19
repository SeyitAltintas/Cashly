import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../../core/utils/image_utils.dart';
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

  ImageProvider? _cachedProfileImage;

  @override
  void initState() {
    super.initState();
    _formState = UserLoginFormState();
    _formState.addListener(_onStateChanged);

    if (widget.targetUser.profileImage?.isNotEmpty ?? false) {
      _cachedProfileImage = ImageUtils.getProfileImageProvider(
        widget.targetUser.profileImage,
      );
    }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Image.asset(
                Theme.of(context).brightness == Brightness.light
                    ? 'assets/image/seffaflogosiyah.png'
                    : 'assets/image/seffaflogo.png',
                height: 35,
              ),
              const SizedBox(height: 80),

              // Profil Resmi
              _buildProfileAvatar(),
              const SizedBox(height: 20),

              // Kullanıcı İsmi
              _buildUserNameRow(),
              const SizedBox(height: 60),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withValues(alpha: 0.37)
                          : Colors.black.withValues(alpha: 0.1),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E1E1E).withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PIN Girişi ve Biyometrik Buton
                        _buildPinInputRow(),

                        // PIN Hata Mesajı
                        if (_pinErrorMessage != null) _buildErrorMessage(),
                        const SizedBox(height: 24),

                        // Giriş Butonu
                        _buildLoginButton(),
                      ],
                    ),
                    ),
                  ),
                ),
              ),
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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: CircleAvatar(
          radius: 50,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          backgroundImage: _cachedProfileImage,
          child: (widget.targetUser.profileImage?.isEmpty ?? true)
              ? Icon(
                  Icons.person,
                  size: 60,
                  color: Theme.of(context).colorScheme.onSurface,
                )
              : null,
        ),
    );
  }

  Widget _buildUserNameRow() {
    return Text(
      widget.targetUser.name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPinInputRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Giriş Şifresi",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // PIN Alanı
            Expanded(
              child: TextField(
                controller: _pinController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  letterSpacing: 6,
                ),
                keyboardType: TextInputType.number,
                obscureText: !_isPinVisible,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : Colors.white.withValues(alpha: 0.8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 16,
                  ),
                  hintText: "● ● ● ● ● ●",
                  hintStyle: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.54),
                    letterSpacing: 4,
                    fontSize: 16,
                  ),
                  counterText: "",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: Theme.of(context).brightness == Brightness.light
                        ? BorderSide(color: Colors.black.withValues(alpha: 0.1))
                        : BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
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

            // Biyometrik Buton
            if (widget.targetUser.biometricEnabled == true &&
                widget.isBiometricAvailable)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Tooltip(
                  message: "Parmak izi ile giriş",
                  child: InkWell(
                    onTap: _isLoading ? null : _handleBiometricLogin,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : Colors.white.withValues(alpha: 0.8),
                      ),
                      child: Icon(
                        Icons.fingerprint,
                        size: 30,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
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
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePinLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              )
            : Text(
                context.l10n.login,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.login,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.loginWithAnotherAccount,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: widget.onForgotPassword,
          child: Text(
            context.l10n.forgotPassword,
            style: TextStyle(
              fontSize: 13,
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
