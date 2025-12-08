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
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
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
                const SizedBox(height: 40),
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
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.24),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
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
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: !_isPinVisible,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  validator: Validators.validatePIN,
                  decoration: InputDecoration(
                    hintText: "PIN",
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.24),
                      letterSpacing: 2,
                    ),
                    counterText: "",
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
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.24),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
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
                        borderRadius: BorderRadius.circular(12),
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

                // Register Link
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            SignUpPage(authController: widget.authController),
                      ),
                    );
                  },
                  child: Text(
                    "Hesabınız yok mu? Kayıt Ol",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
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

              // PIN Girişi
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _pinController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: !_isPinVisible,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "PIN",
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.24),
                      letterSpacing: 2,
                    ),
                    counterText: "",
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinVisible ? Icons.visibility : Icons.visibility_off,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinVisible = !_isPinVisible;
                        });
                      },
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.24),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Giriş Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_pinController.text.isEmpty) return;

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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            widget.authController.error ?? "Hatalı PIN",
                          ),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Giriş Yap",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Biyometrik Giriş Butonu
              if (_targetUser?.biometricEnabled == true &&
                  _isBiometricAvailable)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleBiometricLogin,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(
                          Icons.fingerprint,
                          size: 28,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(
                          "Parmak İzi ile Giriş",
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Google ile Giriş (UI Only)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Backend bağlantısı yok
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.24),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: 32,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  label: Text(
                    "Google ile Giriş Yap",
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          title: Text(
                            "Şifremi Unuttum",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          content: TextField(
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: "E-posta adresinizi girin",
                              hintStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.54),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.24),
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                "İptal",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Sıfırlama bağlantısı gönderildi (Simülasyon)",
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                "Gönder",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
}
