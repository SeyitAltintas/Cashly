import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/user_entity.dart';
import '../controllers/auth_controller.dart';
import 'login_page.dart';
import 'signup_page.dart';

class UserListPage extends StatefulWidget {
  final AuthController authController;

  const UserListPage({super.key, required this.authController});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<UserEntity> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await widget.authController.getAllUsers();
    if (mounted) {
      setState(() {
        _users = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Kullanıcılar",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9D00FF)),
            )
          : _users.isEmpty
          ? Center(
              child: Text(
                "Kayıtlı kullanıcı yok.",
                style: GoogleFonts.outfit(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(
                        0xFF9D00FF,
                      ).withValues(alpha: 0.2),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFBB86FC),
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: GoogleFonts.outfit(color: Colors.white54),
                    ),
                    onTap: () {
                      // Seçilen kullanıcı ile giriş ekranına dön
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoginPage(
                            authController: widget.authController,
                            preSelectedUser: user,
                          ),
                        ),
                      );
                    },
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white24,
                      size: 16,
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              // Mevcut oturumu kapat ve kayıt ekranına git
              widget.authController.logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      SignUpPage(authController: widget.authController),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF9D00FF)),
              ),
            ),
            icon: const Icon(Icons.add, color: Color(0xFFBB86FC)),
            label: const Text(
              "Yeni Kullanıcı Ekle",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
