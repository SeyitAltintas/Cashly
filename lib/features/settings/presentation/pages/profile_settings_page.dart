import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../services/biometric_service.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// Modüler widget'lar
import '../widgets/profile/profile_photo_section.dart';
import '../widgets/profile/profile_info_cards.dart';
import '../widgets/profile/security_section.dart';
import '../widgets/profile/danger_zone_section.dart';
import '../widgets/profile/profile_settings_helper.dart';

/// Profil Ayarları Sayfası
/// Kullanıcı profili yönetimi için ana sayfa
class ProfileSettingsPage extends StatefulWidget {
  final AuthController authController;

  const ProfileSettingsPage({super.key, required this.authController});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final _authRepository = AuthRepositoryImpl();
  final BiometricService _biometricService = BiometricService();
  UserEntity? _currentUser;
  bool _isLoading = true;
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _checkBiometricAvailability();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      _currentUser = widget.authController.currentUser;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(
          context,
          "Kullanıcı bilgileri yüklenemedi",
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      setState(() => _isBiometricAvailable = isAvailable);
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');
    return formatter.format(date);
  }

  ProfileSettingsHelper _getHelper() {
    return ProfileSettingsHelper(
      context: context,
      authController: widget.authController,
      currentUser: _currentUser!,
      authRepository: _authRepository,
      onUserUpdated: () {
        setState(() {
          _currentUser = widget.authController.currentUser;
        });
      },
    );
  }

  Future<void> _handleBiometricToggle(bool enabled) async {
    if (_currentUser == null) return;

    if (enabled) {
      _getHelper().showPinVerificationForBiometric(() async {
        await widget.authController.setBiometricEnabled(_currentUser!.id, true);
        setState(() {
          _currentUser = widget.authController.currentUser;
        });
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            "Biyometrik giriş aktifleştirildi",
          );
        }
      });
    } else {
      await widget.authController.setBiometricEnabled(_currentUser!.id, false);
      setState(() {
        _currentUser = widget.authController.currentUser;
      });
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, "Biyometrik giriş kapatıldı");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yükleme durumu
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil Ayarları"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Kullanıcı bulunamadı
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil Ayarları"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Kullanıcı bulunamadı",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final helper = _getHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Ayarları"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profil Fotoğrafı Bölümü
            ProfilePhotoSection(
              user: _currentUser!,
              onPhotoTap: helper.showFullScreenImage,
              onEditTap: helper.showAvatarSelectionDialog,
            ),

            // Bilgi Kartları (İsim, E-posta, PIN)
            ProfileInfoCards(
              name: _currentUser!.name,
              email: _currentUser!.email,
              createdAt: _formatDate(_currentUser!.createdAt),
              lastLoginAt: _currentUser!.lastLoginAt != null
                  ? _formatDate(_currentUser!.lastLoginAt!)
                  : "Bilinmiyor",
              onNameTap: helper.showNameChangeSheet,
              onPinTap: helper.showPinChangeSheet,
            ),

            // Güvenlik Bölümü (Biyometrik, Tarihler)
            SecuritySection(
              isBiometricAvailable: _isBiometricAvailable,
              biometricEnabled: _currentUser?.biometricEnabled ?? false,
              createdAt: _formatDate(_currentUser!.createdAt),
              lastLoginAt: _currentUser!.lastLoginAt != null
                  ? _formatDate(_currentUser!.lastLoginAt!)
                  : "Bilinmiyor",
              onBiometricToggle: _handleBiometricToggle,
            ),

            // Tehlikeli Bölge (Hesap Silme)
            DangerZoneSection(onDeleteAccount: helper.showDeleteAccountDialog),
          ],
        ),
      ),
    );
  }
}
