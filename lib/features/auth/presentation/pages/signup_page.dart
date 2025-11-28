import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/auth_controller.dart';
import '../../../../home_page.dart'; // AnaSayfa için
import 'login_page.dart';

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
  bool _isPinVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Image.asset('assets/image/seffaflogo.png', height: 80),
                ),
                const SizedBox(height: 40),
                Text(
                  "Hesap Oluştur",
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Harcamalarınızı yönetmeye başlamak için kayıt olun.",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),

                // İsim Soyisim
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "İsim Soyisim",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.person_outline,
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
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen isminizi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // E-posta
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
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
                    errorStyle: const TextStyle(color: Color(0xFFCF6679)),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen e-posta adresinizi girin';
                    }
                    final emailRegex = RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    );
                    if (!emailRegex.hasMatch(value)) {
                      return 'Geçerli bir e-posta adresi girin';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // PIN
                TextFormField(
                  controller: _pinController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  obscureText: !_isPinVisible,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: "PIN (4-6 Rakam)",
                    labelStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFFBB86FC),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPinVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinVisible = !_isPinVisible;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF9D00FF)),
                    ),
                    errorStyle: const TextStyle(color: Color(0xFFCF6679)),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCF6679)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Lütfen bir PIN belirleyin';
                    }
                    if (value.length < 4 || value.length > 6) {
                      return 'PIN 4 ile 6 rakam arasında olmalıdır';
                    }
                    if (int.tryParse(value) == null) {
                      return 'PIN sadece rakamlardan oluşmalıdır';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // Kayıt Ol Butonu
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await widget.authController.register(
                          _nameController.text,
                          _emailController.text,
                          _pinController.text,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => AnaSayfa(
                                authController: widget.authController,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                widget.authController.error ??
                                    "Bir hata oluştu",
                              ),
                              backgroundColor: const Color(0xFFCF6679),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9D00FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Kayıt Ol",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Giriş Yap'a Dön
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginPage(authController: widget.authController),
                        ),
                      );
                    },
                    child: const Text(
                      "Zaten hesabınız var mı? Giriş Yap",
                      style: TextStyle(color: Color(0xFFBB86FC)),
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
