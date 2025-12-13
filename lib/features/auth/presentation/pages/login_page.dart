import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../../home_page.dart';
import 'signup_page.dart';
import 'user_list_page.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../services/biometric_service.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _pinController = TextEditingController();
  final BiometricService _biometricService = BiometricService();
  bool _isPinVisible = false;
  UserEntity? _targetUser;
  bool _isLoadingUser = true;
  bool _isGenericLogin = false;
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String? _pinErrorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedUser != null) {
      _targetUser = widget.preSelectedUser;
      _isLoadingUser = false;
      // Biyometrik mevcutiyetini kontrol et
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
          // No users found, switch to generic login (which acts as entry to Sign Up or Login)
          _isGenericLogin = true;
        }
        _isLoadingUser = false;
      });

      // Biyometrik mevcutiyetini kontrol et
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

  Future<void> _handleBiometricLogin() async {
    if (_targetUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Biyometrik doğrulama yap
      final authenticated = await _biometricService.authenticate(
        reason: 'Giriş yapmak için kimliğinizi doğrulayın',
      );

      if (!mounted) return;

      if (authenticated) {
        // Biyometrik başarılı, giriş yap
        final success = await widget.authController.loginWithBiometric(
          _targetUser!.id,
        );

        if (!mounted) return;

        if (success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => AnaSayfa(authController: widget.authController),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.authController.error ?? "Biyometrik giriş başarısız",
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Biyometrik doğrulama başarısız: $e"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    // If generic login is active or no target user is selected
    if (_isGenericLogin || _targetUser == null) {
      return _buildGenericLogin();
    }

    return _buildUserLogin();
  }

  Widget _buildGenericLogin() {
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
                Image.asset('assets/image/seffaflogo.png', height: 100),
                const SizedBox(height: 120),
                Text(
                  "Giriş Yap",
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    labelText: "E-posta",
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
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // PIN Field
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
                        setState(() {
                          _isPinVisible = !_isPinVisible;
                        });
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
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    errorStyle: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            // Form validation
                            if (!_formKey.currentState!.validate()) {
                              return;
                            }

                            setState(() {
                              _isLoading = true;
                            });

                            try {
                              final success = await widget.authController
                                  .loginByEmail(
                                    _emailController.text.trim(),
                                    _pinController.text,
                                  );

                              if (!mounted) return;

                              if (success) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => AnaSayfa(
                                      authController: widget.authController,
                                    ),
                                  ),
                                );
                              } else {
                                ErrorHandler.showErrorSnackBar(
                                  context,
                                  widget.authController.error ??
                                      "Giriş başarısız. E-posta veya PIN hatalı.",
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ErrorHandler.handleDatabaseError(context, e);
                              }
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
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
                        : const Text(
                            "Giriş Yap",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Kayıt Ol ve Şifremi Unuttum butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Register Link (Sol)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignUpPage(
                              authController: widget.authController,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Hesabınız yok mu? Kayıt olun",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                    // Şifremi Unuttum (Sağ)
                    TextButton(
                      onPressed: () => _showForgotPasswordSheet(context),
                      child: Text(
                        "Şifremi Unuttum",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserLogin() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/image/seffaflogo.png', height: 100),
              const SizedBox(height: 40),

              // Profil Resmi
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                backgroundImage: _targetUser?.profileImage != null
                    ? (_targetUser!.profileImage!.startsWith('http')
                              ? NetworkImage(_targetUser!.profileImage!)
                              : (_targetUser!.profileImage!.startsWith(
                                      'lib/',
                                    ) ||
                                    _targetUser!.profileImage!.startsWith(
                                      'assets/',
                                    ))
                              ? AssetImage(_targetUser!.profileImage!)
                              : FileImage(File(_targetUser!.profileImage!)))
                          as ImageProvider
                    : null,
                child: _targetUser?.profileImage == null
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.onSurface,
                      )
                    : null,
              ),
              const SizedBox(height: 20),

              // Hoşgeldiniz Mesajı
              Text(
                "Hoşgeldiniz",
                style: GoogleFonts.outfit(
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
                      _targetUser!.name,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(
                        Icons.autorenew_sharp,
                        color: Colors.white,
                      ),
                      tooltip: "Kullanıcı Değiştir",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserListPage(
                              authController: widget.authController,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),

              // PIN Girişi ve Biyometrik Buton - Yan yana (esnek genişlik)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // PIN Alanı - Expanded ile esnek genişlik
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                              _isPinVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPinVisible = !_isPinVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Biyometrik Buton - PIN'in sağında (sabit genişlik)
                  if (_targetUser?.biometricEnabled == true &&
                      _isBiometricAvailable)
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
              ),

              // PIN Hata Mesajı (inline)
              if (_pinErrorMessage != null)
                Padding(
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
                ),
              const SizedBox(height: 40),

              // Giriş Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // Önceki hata mesajını temizle
                    setState(() {
                      _pinErrorMessage = null;
                    });

                    if (_pinController.text.isEmpty) {
                      setState(() {
                        _pinErrorMessage = "Lütfen PIN giriniz";
                      });
                      return;
                    }

                    final success = await widget.authController.login(
                      _targetUser!.id,
                      _pinController.text,
                    );

                    if (!mounted) return;

                    if (success) {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) =>
                              AnaSayfa(authController: widget.authController),
                        ),
                      );
                    } else {
                      setState(() {
                        _pinErrorMessage =
                            widget.authController.error ??
                            "Hatalı PIN veya kullanıcı bulunamadı";
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // "veya" ayırıcısı - sadece alternatif giriş seçenekleri varsa göster
              if (_isBiometricAvailable || true) // Google her zaman görünür
                Row(
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
                        "veya",
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
                ),
              const SizedBox(height: 24),

              // Alternatif giriş - Google butonu
              SizedBox(
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
                          "Google ile Giriş Yap",
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
              ),
              const SizedBox(height: 24),

              // Başka Hesap / Şifremi Unuttum
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isGenericLogin = true;
                      });
                    },
                    child: Text(
                      "Başka hesap ile giriş yap",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showForgotPasswordSheet(context),
                    child: Text(
                      "Şifremi Unuttum",
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Şifremi Unuttum - Ana BottomSheet (E-posta girişi)
  void _showForgotPasswordSheet(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      "Şifremi Unuttum",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Kayıtlı e-posta adresinizi girin",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: "E-posta",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Theme.of(sheetContext).colorScheme.secondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.primary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.error,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen e-posta adresinizi girin';
                        }
                        if (!value.contains('@')) {
                          return 'Geçerli bir e-posta adresi girin';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        // Kullanıcı yazmaya başladığında hata mesajını temizle
                        if (errorMessage != null) {
                          setSheetState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    // Inline hata mesajı
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              builderContext,
                            ).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(builderContext).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(
                                    builderContext,
                                  ).colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final email = emailController.text.trim();
                          final user = await widget.authController
                              .getUserByEmail(email);

                          if (!context.mounted) return;

                          if (user == null) {
                            setSheetState(() {
                              errorMessage =
                                  "Bu e-posta adresi ile kayıtlı kullanıcı bulunamadı";
                            });
                            return;
                          }

                          if (user.securityQuestion == null ||
                              user.securityAnswer == null) {
                            setSheetState(() {
                              errorMessage =
                                  "Bu hesap için güvenlik sorusu tanımlanmamış";
                            });
                            return;
                          }

                          Navigator.pop(sheetContext);
                          if (context.mounted) {
                            _showSecurityQuestionSheet(
                              context,
                              email,
                              user.securityQuestion!,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            sheetContext,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "Devam",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Şifremi Unuttum - Güvenlik Sorusu BottomSheet
  void _showSecurityQuestionSheet(
    BuildContext context,
    String email,
    String securityQuestion,
  ) {
    final answerController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      "Güvenlik Sorusu",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          sheetContext,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(sheetContext).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              securityQuestion,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  sheetContext,
                                ).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: answerController,
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: "Cevabınız",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            sheetContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        prefixIcon: Icon(
                          Icons.question_answer_outlined,
                          color: Theme.of(sheetContext).colorScheme.secondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(
                              sheetContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.primary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(sheetContext).colorScheme.error,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Lütfen cevabınızı girin';
                        }
                        return null;
                      },
                    ),
                    // Hata mesajı
                    if (errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              builderContext,
                            ).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(builderContext).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(
                                    builderContext,
                                  ).colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final answer = answerController.text;
                          final user = await widget.authController
                              .getUserByEmail(email);

                          if (!context.mounted) return;

                          if (user == null) {
                            setSheetState(() {
                              errorMessage = "Kullanıcı bulunamadı";
                            });
                            return;
                          }

                          // Cevabı normalize et ve karşılaştır
                          final normalizedAnswer = answer.trim().toLowerCase();
                          if (user.securityAnswer != normalizedAnswer) {
                            setSheetState(() {
                              errorMessage =
                                  "Yanlış cevap! Lütfen tekrar deneyin.";
                            });
                            return;
                          }

                          Navigator.pop(sheetContext);
                          if (context.mounted) {
                            _showNewPinSheet(context, email);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            sheetContext,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "Doğrula",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Şifremi Unuttum - Yeni PIN BottomSheet
  void _showNewPinSheet(BuildContext context, String email) {
    final pinController = TextEditingController();
    final confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;
    String? errorMessage;
    String? successMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      "Yeni PIN Belirle",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(builderContext).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "4-6 haneli yeni PIN kodunuzu girin",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          builderContext,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      obscureText: !isPinVisible,
                      maxLength: 6,
                      style: TextStyle(
                        color: Theme.of(builderContext).colorScheme.onSurface,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        labelText: "Yeni PIN",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        counterText: "",
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(builderContext).colorScheme.secondary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPinVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(
                              builderContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                          onPressed: () {
                            setSheetState(() {
                              isPinVisible = !isPinVisible;
                            });
                          },
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(
                              builderContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.primary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.error,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen yeni PIN girin';
                        }
                        if (value.length < 4) {
                          return 'PIN en az 4 haneli olmalı';
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'PIN sadece rakamlardan oluşmalı';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // PIN Onay Alanı
                    TextFormField(
                      controller: confirmPinController,
                      keyboardType: TextInputType.number,
                      obscureText: !isPinVisible,
                      maxLength: 6,
                      style: TextStyle(
                        color: Theme.of(builderContext).colorScheme.onSurface,
                        letterSpacing: 4,
                      ),
                      decoration: InputDecoration(
                        labelText: "PIN Tekrar",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            builderContext,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        counterText: "",
                        prefixIcon: Icon(
                          Icons.lock_reset,
                          color: Theme.of(builderContext).colorScheme.secondary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(
                              builderContext,
                            ).colorScheme.onSurface.withValues(alpha: 0.24),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.primary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.error,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide: BorderSide(
                            color: Theme.of(builderContext).colorScheme.error,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen PIN\'i tekrar girin';
                        }
                        if (value != pinController.text) {
                          return 'PIN\'ler eşleşmiyor';
                        }
                        return null;
                      },
                    ),
                    // Hata veya Başarı Mesajı
                    if (errorMessage != null || successMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: successMessage != null
                              ? Colors.green.withValues(alpha: 0.1)
                              : Theme.of(
                                  builderContext,
                                ).colorScheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: successMessage != null
                                ? Colors.green.withValues(alpha: 0.3)
                                : Theme.of(
                                    builderContext,
                                  ).colorScheme.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              successMessage != null
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color: successMessage != null
                                  ? Colors.green
                                  : Theme.of(builderContext).colorScheme.error,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                successMessage ?? errorMessage!,
                                style: TextStyle(
                                  color: successMessage != null
                                      ? Colors.green
                                      : Theme.of(
                                          builderContext,
                                        ).colorScheme.error,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final newPin = pinController.text;

                          // Kullanıcıyı bul ve PIN'i güncelle
                          final user = await widget.authController
                              .getUserByEmail(email);
                          if (user != null) {
                            await widget.authController.updateUserPin(
                              user.id,
                              newPin,
                            );

                            setSheetState(() {
                              successMessage = "PIN başarıyla güncellendi! ✓";
                              errorMessage = null;
                            });

                            // 1.5 saniye bekle ve kapat
                            await Future.delayed(
                              const Duration(milliseconds: 1500),
                            );
                            if (!context.mounted) return;
                            Navigator.pop(sheetContext);
                          } else {
                            setSheetState(() {
                              errorMessage = "Kullanıcı bulunamadı";
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            builderContext,
                          ).colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: const Text(
                          "PIN'i Güncelle",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
