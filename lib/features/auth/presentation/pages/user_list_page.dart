import 'package:flutter/material.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import 'package:cashly/features/auth/presentation/controllers/auth_controller.dart';
import '../../../../core/utils/image_utils.dart';
import '../../domain/entities/user_entity.dart';
import 'login_page.dart';
import 'signup_page.dart';
import '../state/user_list_state.dart';

class UserListPage extends StatefulWidget {
  final AuthController authController;

  const UserListPage({super.key, required this.authController});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late final UserListState _listState;

  List<UserEntity> get _users => _listState.users;
  bool get _isLoading => _listState.isLoading;

  @override
  void initState() {
    super.initState();
    _listState = UserListState();
    _listState.addListener(_onStateChanged);
    _loadUsers();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _listState.removeListener(_onStateChanged);
    _listState.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final users = await widget.authController.getAllUsers();
    if (mounted) {
      _listState.setUsersLoaded(users);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.l10n.users,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _users.isEmpty
          ? Center(
              child: Text(
                context.l10n.noRegisteredUsers,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Colors.white70,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  color: Theme.of(context).colorScheme.surface,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.05),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                      backgroundImage: user.profileImage != null
                          ? ImageUtils.getProfileImageProvider(user.profileImage)
                          : null,
                      child: user.profileImage == null
                          ? Text(
                              user.name[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            )
                          : null,
                    ),
                    title: Text(
                      user.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      user.email,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white54,
                      ),
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
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.secondary,
            ),
            label: Text(
              context.l10n.addNewUser,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
