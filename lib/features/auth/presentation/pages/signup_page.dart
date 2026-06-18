import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../controllers/auth_controller.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../state/signup_page_state.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  final AuthController authController;

  const SignUpPage({super.key, required this.authController});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isConfirmPinVisible = false;

  late final SignupPageState _signupState;

  // Kullanıcı formu bir kez submit etmeye çalıştığında gerçek zamanlı validasyonu aktif et
  bool _submitted = false;

  bool get _isPinVisible => _signupState.isPinVisible;
  bool get _isLoading => _signupState.isLoading;

  @override
  void initState() {
    super.initState();
    _signupState = SignupPageState();
    _signupState.addListener(_onStateChanged);
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _signupState.removeListener(_onStateChanged);
    _signupState.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
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
                      context.l10n.createAccount,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.signupSubtitleExpense,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 40),

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
                              // İsim Soyisim
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      context.l10n.fullName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _nameController,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    validator: Validators.validateName,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white.withValues(alpha: 0.8),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                              ),
                              const SizedBox(height: 20),

                              // E-posta
                              Column(
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
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: Validators.validateEmail,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white.withValues(alpha: 0.8),
                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                              ),
                              const SizedBox(height: 20),

                              // PIN
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      context.l10n.pinLabel,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: !_isPinVisible,
                                    maxLength: 6,
                                    validator: Validators.validatePIN,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white.withValues(alpha: 0.8),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPinVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.9),
                                    ),
                                    onPressed: () {
                                      _signupState.isPinVisible =
                                          !_isPinVisible;
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                              ),
                              const SizedBox(height: 20),

                              // PIN Doğrula
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                                    child: Text(
                                      context.l10n.newPinRepeatLabel,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _confirmPinController,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                    keyboardType: TextInputType.number,
                                    obscureText: !_isConfirmPinVisible,
                                    maxLength: 6,
                                    validator: (value) {
                                      final pinValid = Validators.validatePIN(
                                        value,
                                      );
                                      if (pinValid != null) return pinValid;
                                      if (value != _pinController.text) {
                                        return context.l10n.pinsDoNotMatch;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF2A2A2A)
                                          : Colors.white.withValues(alpha: 0.8),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmPinVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.9),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmPinVisible =
                                            !_isConfirmPinVisible;
                                      });
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                  errorStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                              ),
                              const SizedBox(height: 40),

                              // Kayıt Ol Butonu
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.15),
                                      blurRadius: 20,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                          setState(() => _submitted = true);
                                          if (!_formKey.currentState!
                                              .validate()) {
                                            return;
                                          }

                                          // Context bağımlılıklarını async işlemden önce yakala
                                          final messenger =
                                              ScaffoldMessenger.of(context);

                                          _signupState.isLoading = true;

                                          try {
                                            final success = await widget
                                                .authController
                                                .register(
                                                  _nameController.text.trim(),
                                                  _emailController.text.trim(),
                                                  _pinController.text,
                                                );

                                            if (!context.mounted) return;

                                            if (success) {
                                              AppSnackBar.successWithMessenger(
                                                messenger,
                                                context.l10n.signupSuccess,
                                              );
                                              if (!context.mounted) return;
                                              // GÜVENLİK/MİMARİ YAMASI: Duplicate Routing Fix
                                              context.go('/');
                                            } else {
                                              AppSnackBar.errorWithMessenger(
                                                messenger,
                                                widget.authController.error ??
                                                    context.l10n.signupError,
                                              );
                                            }
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            AppSnackBar.errorWithMessenger(
                                              messenger,
                                              "Hata: ${e.toString()}",
                                            );
                                          } finally {
                                            if (mounted) {
                                              _signupState.isLoading = false;
                                            }
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
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
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                        )
                                      : Text(
                                          context.l10n.signup,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    ),
                    const SizedBox(height: 20),

                    // Giriş Yap'a Dön
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/login');
                          }
                        },
                        child: Text(
                          context.l10n.alreadyHaveAccount,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
    );
  }
}
