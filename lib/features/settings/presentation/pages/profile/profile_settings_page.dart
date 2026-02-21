import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../../core/utils/error_handler.dart';
import '../../../../../core/services/biometric_service.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';

// Modüler widget'lar
import '../../widgets/profile/profile_photo_section.dart';
import '../../widgets/profile/profile_info_cards.dart';
import '../../widgets/profile/security_section.dart';
import '../../widgets/profile/danger_zone_section.dart';
import '../../widgets/profile/profile_settings_helper.dart';
import 'state/profile_settings_state.dart';

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
  late final ProfileSettingsState _profileState;

  UserEntity? get _currentUser => _profileState.currentUser;
  bool get _isLoading => _profileState.isLoading;
  bool get _isBiometricAvailable => _profileState.isBiometricAvailable;

  @override
  void initState() {
    super.initState();
    _profileState = ProfileSettingsState();
    _profileState.addListener(_onStateChanged);
    _loadUserData();
    _checkBiometricAvailability();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _profileState.removeListener(_onStateChanged);
    _profileState.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _profileState.isLoading = true;
    try {
      _profileState.currentUser = widget.authController.currentUser;
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, context.l10n.userLoadError);
      }
    } finally {
      _profileState.isLoading = false;
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (mounted) {
      _profileState.isBiometricAvailable = isAvailable;
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
        _profileState.currentUser = widget.authController.currentUser;
      },
    );
  }

  Future<void> _handleBiometricToggle(bool enabled) async {
    if (_currentUser == null) return;

    if (enabled) {
      _getHelper().showPinVerificationForBiometric(() async {
        await widget.authController.setBiometricEnabled(_currentUser!.id, true);
        _profileState.currentUser = widget.authController.currentUser;
        if (mounted) {
          ErrorHandler.showSuccessSnackBar(
            context,
            context.l10n.biometricEnabled,
          );
        }
      });
    } else {
      await widget.authController.setBiometricEnabled(_currentUser!.id, false);
      _profileState.currentUser = widget.authController.currentUser;
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          context.l10n.biometricDisabled,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yükleme durumu
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.profileSettingsTitle),
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
          title: Text(context.l10n.profileSettingsTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: Text(
            context.l10n.userNotFound,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final helper = _getHelper();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileSettingsTitle),
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
                  : context.l10n.unknownDate,
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
                  : context.l10n.unknownDate,
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
