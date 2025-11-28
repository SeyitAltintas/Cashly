import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import '../../../../home_page.dart';
import 'signup_page.dart';
import 'user_list_page.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/error_handler.dart';

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
  bool _isPinVisible = false;
  UserEntity? _targetUser;
  bool _isLoadingUser = true;
  bool _isGenericLogin = false;
  bool _isLoading = false;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF9D00FF)),
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
      backgroundColor: Colors.black,
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
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  decoration: InputDecoration(
                    labelText: "E-posta",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFFBB86FC),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9D00FF)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                    errorStyle: const TextStyle(color: Color(0xFFCF6679)),
                  ),
                ),
                const SizedBox(height: 20),

                // PIN Field
                TextFormField(
                  controller: _pinController,
                  style: const TextStyle(
                    color: Colors.white,
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
                    hintStyle: const TextStyle(
                      color: Colors.white24,
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
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D00FF)),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCF6679)),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFCF6679)),
                    ),
                    errorStyle: const TextStyle(
                      color: Color(0xFFCF6679),
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
                    onPressed: _isLoading ? null : () async {
                      // Form validation
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      setState(() {
                        _isLoading = true;
                      });

                      try {
                        final success = await widget.authController.loginByEmail(
                          _emailController.text.trim(),
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
                          ErrorHandler.showErrorSnackBar(
                            context,
                            widget.authController.error ?? "Giriş başarısız. E-posta veya PIN hatalı.",
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
                      backgroundColor: const Color(0xFF9D00FF),
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
                child: const Text(
                  "Hesabınız yok mu? Kayıt Ol",
                  style: TextStyle(color: Color(0xFFBB86FC)),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildUserLogin() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Image.asset('assets/image/seffaflogo.png', height: 100),
              const SizedBox(height: 80),

              // Hoşgeldiniz Mesajı
              Text(
                "Hoşgeldiniz",
                style: GoogleFonts.outfit(fontSize: 24, color: Colors.white70),
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
                        color: Colors.white,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 8,
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: !_isPinVisible,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "PIN",
                    hintStyle: const TextStyle(
                      color: Colors.white24,
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
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF9D00FF)),
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
                          backgroundColor: const Color(0xFFCF6679),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D00FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
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

              // Google ile Giriş (UI Only)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Backend bağlantısı yok
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 32,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Google ile Giriş Yap",
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
                    child: const Text(
                      "Başka hesap ile giriş yap",
                      style: TextStyle(color: Color(0xFFBB86FC)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1E1E1E),
                          title: const Text(
                            "Şifremi Unuttum",
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const TextField(
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "E-posta adresinizi girin",
                              hintStyle: TextStyle(color: Colors.white54),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white24),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "İptal",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Sıfırlama bağlantısı gönderildi (Simülasyon)",
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Gönder",
                                style: TextStyle(color: Color(0xFFBB86FC)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Şifremi Unuttum",
                      style: TextStyle(color: Colors.white70),
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
