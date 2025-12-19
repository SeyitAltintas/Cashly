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

  // Avatar seçimi için profil resim URL'leri
  final List<String> _profileImageUrls = [
    'https://i.pinimg.com/1200x/6d/d4/3f/6dd43f7687480c96d17cb3f5d838c196.jpg',
    'https://i.pinimg.com/736x/bf/7f/71/bf7f711a8bc446ef8df921fe15042925.jpg',
    'https://i.pinimg.com/1200x/53/48/cf/5348cf6370db6337d82b4355a8157b00.jpg',
    'https://i.pinimg.com/1200x/e4/12/3e/e4123efcde55d35d285ab6281bbab0f3.jpg',
    'https://i.pinimg.com/736x/36/0b/45/360b45b94af38e1f6ab544f7b45321aa.jpg',
    'https://i.pinimg.com/736x/1c/fa/85/1cfa857ae56dabad9fb5d10942cb0ff2.jpg',
    'https://i.pinimg.com/736x/67/f8/ab/67f8ab386a6ef0725e8a94e9b00d845c.jpg',
    'https://i.pinimg.com/736x/0e/d6/55/0ed65525329bab4895e290d054599dac.jpg',
    'https://i.pinimg.com/736x/b3/aa/60/b3aa60951eb63e0b3b171d364173d8c5.jpg',
    'https://i.pinimg.com/736x/56/cc/b2/56ccb267ea83cabdbb9f157616022b24.jpg',
    'https://i.pinimg.com/736x/bc/3a/5f/bc3a5f291e070745f25057144944c66d.jpg',
    'https://i.pinimg.com/736x/dd/ca/8e/ddca8e99d2325e6e574df625424bad49.jpg',
    'https://i.pinimg.com/736x/cc/d0/dd/ccd0dd1f0f561101259cc7554a4b5bc1.jpg',
    'https://i.pinimg.com/736x/f5/25/3b/f5253b2cfbd46d12316f8d4cec534052.jpg',
    'https://i.pinimg.com/736x/5d/b4/96/5db496cea9790626a0dcf1787fb9837f.jpg',
    'https://i.pinimg.com/1200x/51/a6/c3/51a6c3d66cfa74388cd0e4fa2f4301ed.jpg',
    'https://i.pinimg.com/736x/1c/5d/c9/1c5dc9612439697e280936047560042f.jpg',
    'https://i.pinimg.com/1200x/80/07/4b/80074b333e85ebb331371f02583f7f73.jpg',
    'https://i.pinimg.com/736x/dc/8a/96/dc8a9690392ee092db0a66bcd2b98d6f.jpg',
    'https://i.pinimg.com/736x/9c/b7/18/9cb7185c47a0674d6e02a037bfe2558d.jpg',
    'https://i.pinimg.com/736x/db/52/fe/db52fe21f541608ab04c2e5291e428cd.jpg',
    'https://i.pinimg.com/736x/88/01/a7/8801a7c9b02f1b7dc7dc4520c23348d7.jpg',
    'https://i.pinimg.com/736x/ab/29/ea/ab29eab9d5548f8c0b45a9c33efdb8b5.jpg',
    'https://i.pinimg.com/736x/b4/8c/fd/b48cfd5f84af8fb4f79ec4f0e4e5495e.jpg',
    'https://i.pinimg.com/736x/f5/e2/24/f5e2248a2c98e1b4c6fd70cf59e4b5c2.jpg',
    'https://i.pinimg.com/736x/4a/a8/5a/4aa85a5bf097d6bd61045511390aa117.jpg',
    'https://i.pinimg.com/736x/b9/7d/62/b97d6252b691e088b8b6076911630432.jpg',
    'https://i.pinimg.com/1200x/0f/d2/0f/0fd20f94fa92b7bb95308e788639a098.jpg',
    'https://i.pinimg.com/736x/24/4d/39/244d39bfbb6a9905481dcdb0253be97d.jpg',
    'https://i.pinimg.com/736x/4c/91/75/4c9175bf510238f3cb5cac874b31b2dd.jpg',
    'https://i.pinimg.com/736x/04/2f/28/042f282616fffb018da976899dd03882.jpg',
    'https://i.pinimg.com/736x/54/a0/aa/54a0aa3eb0bb81ccb0be7e1e70b19807.jpg',
  ];

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
      profileImageUrls: _profileImageUrls,
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
