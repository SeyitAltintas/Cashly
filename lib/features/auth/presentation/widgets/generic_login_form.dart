import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import 'dart:ui';
import '../state/login_form_state.dart';

/// E-posta ve PIN ile giriş formu widget'ı
/// Generic login ekranı - kullanıcı seçimi yapılmadığında gösterilir
class GenericLoginForm extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;
  final VoidCallback? onBackToPinLogin;

  const GenericLoginForm({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
    required this.onSignUp,
    required this.onForgotPassword,
    this.onBackToPinLogin,
  });

  @override
  State<GenericLoginForm> createState() => _GenericLoginFormState();
}

class _GenericLoginFormState extends State<GenericLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  late final LoginFormState _formState;

  // Getter'lar
  bool get _isLoading => _formState.isLoading;
  bool get _isPinVisible => _formState.isPinVisible;

  @override
  void initState() {
    super.initState();
    _formState = LoginFormState();
    _formState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _formState.removeListener(_onStateChanged);
    _formState.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formState.startLoading();

    try {
      final success = await widget.authController.loginByEmail(
        _emailController.text.trim(),
        _pinController.text,
      );

      if (!mounted) return;

      if (success) {
        widget.onLoginSuccess();
      } else {
        ErrorHandler.showErrorSnackBar(
          context,
          context.l10n.loginFailed(widget.authController.error ?? ''),
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleDatabaseError(context, e);
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
      extendBodyBehindAppBar: true,
      appBar: widget.onBackToPinLogin != null
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.onSurface),
                onPressed: widget.onBackToPinLogin,
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
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
                Text(
                  context.l10n.login,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 40),
                // Form Container (Glassmorphism)
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
                          // Email Field
                          _buildEmailField(),
                          const SizedBox(height: 20),

                          // PIN Field
                          _buildPinField(),
                          const SizedBox(height: 40),

                          // Login Button
                          _buildLoginButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kayıt Ol ve Şifremi Unuttum butonları
              _buildActionButtons(),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.emailLabel,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white.withValues(alpha: 0.8),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
            errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }

  Widget _buildPinField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "PIN",
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        TextFormField(
          controller: _pinController,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            letterSpacing: 4,
          ),
          keyboardType: TextInputType.number,
          obscureText: !_isPinVisible,
          maxLength: 6,
          textAlign: TextAlign.start,
          validator: Validators.validatePIN,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white.withValues(alpha: 0.8),
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.54),
          letterSpacing: 2,
        ),
        counterText: "",
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPinVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.90),
            size: 20,
          ),
          onPressed: () {
            _formState.togglePinVisibility();
          },
        ),
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
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
          errorStyle: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
      ),
      ],
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
        onPressed: _isLoading ? null : _handleLogin,
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
                  fontWeight: FontWeight.bold,
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
        // Register Link (Sol)
        TextButton(
          onPressed: widget.onSignUp,
          child: Text(
            context.l10n.dontHaveAccount,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
        // Şifremi Unuttum (Sağ)
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
