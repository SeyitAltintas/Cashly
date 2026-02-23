import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../state/login_form_state.dart';

/// E-posta ve PIN ile giriş formu widget'ı
/// Generic login ekranı - kullanıcı seçimi yapılmadığında gösterilir
class GenericLoginForm extends StatefulWidget {
  final AuthController authController;
  final VoidCallback onLoginSuccess;
  final VoidCallback onSignUp;
  final VoidCallback onForgotPassword;

  const GenericLoginForm({
    super.key,
    required this.authController,
    required this.onLoginSuccess,
    required this.onSignUp,
    required this.onForgotPassword,
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Image.asset('assets/image/seffaflogo.png', height: 70),
                const SizedBox(height: 120),
                Text(
                  context.l10n.login,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                _buildEmailField(),
                const SizedBox(height: 20),

                // PIN Field
                _buildPinField(),
                const SizedBox(height: 40),

                // Login Button
                _buildLoginButton(),
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
    return TextFormField(
      controller: _emailController,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      decoration: InputDecoration(
        labelText: context.l10n.emailLabel,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Theme.of(context).colorScheme.secondary,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        errorStyle: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget _buildPinField() {
    return TextFormField(
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
        labelText: "PIN",
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.24),
          letterSpacing: 2,
        ),
        counterText: "",
        prefixIcon: Icon(
          Icons.lock_outline,
          color: Theme.of(context).colorScheme.secondary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isPinVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.white70,
            size: 20,
          ),
          onPressed: () {
            _formState.togglePinVisibility();
          },
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.24),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        // Şifremi Unuttum (Sağ)
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
