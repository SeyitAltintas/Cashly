import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cashly/core/extensions/l10n_extensions.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../settings/domain/repositories/settings_repository.dart';
import '../../../../../core/widgets/app_snackbar.dart';
import '../../../../../core/services/image_compression_service.dart';
import 'image_crop_screen.dart';
import 'advanced_image_editor.dart';

/// Profil ayarları dialog/sheet yardımcı sınıfı
/// Avatar seçimi, isim değiştirme, PIN değiştirme, hesap silme akışlarını yönetir
class ProfileSettingsHelper {
  final BuildContext context;
  final AuthController authController;
  final UserEntity currentUser;
  final AuthRepositoryImpl authRepository;
  final VoidCallback onUserUpdated;

  ProfileSettingsHelper({
    required this.context,
    required this.authController,
    required this.currentUser,
    required this.authRepository,
    required this.onUserUpdated,
  });

  /// Yerel dosya veya asset'ten image provider oluştur
  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  Future<void> _updateUser({
    String? name,
    String? pin,
    String? profileImage,
    String? successMessage,
  }) async {
    final updatedUser = UserEntity(
      id: currentUser.id,
      name: name ?? currentUser.name,
      email: currentUser.email,
      pin: pin ?? currentUser.pin,
      profileImage: profileImage ?? currentUser.profileImage,
      createdAt: currentUser.createdAt,
      lastLoginAt: currentUser.lastLoginAt,
      biometricEnabled: currentUser.biometricEnabled,
    );

    try {
      await authRepository.updateUser(updatedUser);
      await authController.checkAuth();
      onUserUpdated();
      if (context.mounted) {
        AppSnackBar.success(
          context,
          successMessage ?? context.l10n.profileUpdated,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, context.l10n.updateFailed(e.toString()));
      }
    }
  }

  /// Yeni gelişmiş akış: Resmi kırp → Düzenle → Kaydet
  Future<void> _processAndSaveImage(String imagePath) async {
    if (!context.mounted) return;

    // Adım 1: Özel kırpma ekranına git
    final File? croppedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => ImageCropScreen(imageFile: File(imagePath)),
      ),
    );

    if (croppedFile == null || !context.mounted) return; // Kullanıcı iptal etti

    // Adım 2: Gelişmiş düzenleme ekranına git
    final File? editedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedImageEditor(imageFile: croppedFile),
      ),
    );

    if (editedFile == null || !context.mounted) return; // Kullanıcı iptal etti

    // Adım 3: Sıkıştır ve kaydet
    final compressionService = ImageCompressionService();
    final compressedPath = await compressionService.optimizeAndSaveProfileImage(
      editedFile,
    );

    if (!context.mounted) return;

    _updateUser(
      profileImage: compressedPath ?? editedFile.path,
      successMessage: context.l10n.profilePhotoUpdated,
    );
    Navigator.pop(context);
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      await _processAndSaveImage(image.path);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await _processAndSaveImage(image.path);
    }
  }

  /// Profil resmi tam ekran gösterimi
  void showFullScreenImage() {
    if (currentUser.profileImage == null) return;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(ctx),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
            InteractiveViewer(
              child: Image(
                image: _getImageProvider(currentUser.profileImage!),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Avatar seçim dialog'u - Sadece galeriden seçim
  void showAvatarSelectionDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetHeader(ctx, context.l10n.selectProfilePhoto),
            const SizedBox(height: 24),
            // Açıklama metni
            Text(
              context.l10n.selectProfilePhotoDesc,
              style: TextStyle(
                color: Theme.of(
                  ctx,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Galeriden Seç butonu
            // Seçenekler: Kamera ve Galeri
            Row(
              children: [
                Expanded(
                  child: _buildSelectionCard(
                    ctx,
                    icon: Icons.camera_alt_rounded,
                    title: context.l10n.camera,
                    subtitle: context.l10n.takePhoto,
                    color: Colors.blue,
                    onTap: _pickImageFromCamera,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectionCard(
                    ctx,
                    icon: Icons.photo_library_rounded,
                    title: context.l10n.gallery,
                    subtitle: context.l10n.choosePhoto,
                    color: Colors.purple,
                    onTap: _pickImageFromGallery,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// İsim değiştirme sheet'i
  void showNameChangeSheet() {
    final TextEditingController nameController = TextEditingController(
      text: currentUser.name,
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(ctx).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSheetHeader(ctx, context.l10n.changeName),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                  decoration: _inputDecoration(ctx, context.l10n.newNameLabel),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return context.l10n.nameCannotBeEmpty;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(ctx, context.l10n.save, () {
                if (formKey.currentState!.validate()) {
                  _updateUser(
                    name: nameController.text.trim(),
                    successMessage: context.l10n.nameUpdated,
                  );
                  Navigator.pop(ctx);
                }
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// PIN değiştirme sheet'i (2 adımlı)
  void showPinChangeSheet() {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmPinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int step = 1;
    bool isCurrentPinVisible = false;
    bool isNewPinVisible = false;
    bool isConfirmPinVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHeader(
                    ctx,
                    step == 1
                        ? context.l10n.currentPinLabel
                        : context.l10n.newPinLabel,
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        if (step == 1)
                          _buildPinField(
                            ctx,
                            currentPinController,
                            context.l10n.currentPinLabel,
                            isCurrentPinVisible,
                            () => setStateBottomSheet(
                              () => isCurrentPinVisible = !isCurrentPinVisible,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length < 4 ||
                                  value.length > 6) {
                                return context.l10n.enterPinDigits;
                              }
                              if (value != currentUser.pin) {
                                return context.l10n.pinIncorrect;
                              }
                              return null;
                            },
                          ),
                        if (step == 2) ...[
                          _buildPinField(
                            ctx,
                            newPinController,
                            context.l10n.newPinLabel,
                            isNewPinVisible,
                            () => setStateBottomSheet(
                              () => isNewPinVisible = !isNewPinVisible,
                            ),
                            autofocus: true,
                            validator: (value) {
                              if (value == null ||
                                  value.length < 4 ||
                                  value.length > 6) {
                                return context.l10n.enterPinDigits;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPinField(
                            ctx,
                            confirmPinController,
                            context.l10n.newPinRepeatLabel,
                            isConfirmPinVisible,
                            () => setStateBottomSheet(
                              () => isConfirmPinVisible = !isConfirmPinVisible,
                            ),
                            validator: (value) {
                              if (value != newPinController.text) {
                                return context.l10n.pinsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(
                    ctx,
                    step == 1 ? context.l10n.forwardButton : context.l10n.save,
                    () {
                      if (formKey.currentState!.validate()) {
                        if (step == 1) {
                          setStateBottomSheet(() => step = 2);
                        } else {
                          _updateUser(
                            pin: newPinController.text,
                            successMessage: context.l10n.pinUpdated,
                          );
                          Navigator.pop(ctx);
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Biyometrik PIN doğrulama sheet'i
  void showPinVerificationForBiometric(VoidCallback onSuccess) {
    final TextEditingController pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHeader(ctx, context.l10n.pinVerification),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.biometricPinVerificationDesc,
                    style: TextStyle(
                      color: Theme.of(
                        ctx,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: _buildPinField(
                      ctx,
                      pinController,
                      "PIN",
                      isPinVisible,
                      () => setStateBottomSheet(
                        () => isPinVisible = !isPinVisible,
                      ),
                      autofocus: true,
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 6) {
                          return context.l10n.enterPinDigits;
                        }
                        if (value != currentUser.pin) {
                          return context.l10n.pinIncorrect;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(ctx);
                          onSuccess();
                        }
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: Text(
                        context.l10n.activateBiometric,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Hesap silme dialog'u
  void showDeleteAccountDialog() {
    final TextEditingController pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.deleteAccount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildWarningBox(),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: _buildPinField(
                      ctx,
                      pinController,
                      context.l10n.pinVerification,
                      isPinVisible,
                      () => setStateBottomSheet(
                        () => isPinVisible = !isPinVisible,
                      ),
                      autofocus: true,
                      focusColor: Colors.red.shade800,
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 6) {
                          return context.l10n.enterPinDigits;
                        }
                        if (value != currentUser.pin) {
                          return context.l10n.pinIncorrect;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDeleteButton(ctx, formKey, pinController),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeleteButton(
    BuildContext ctx,
    GlobalKey<FormState> formKey,
    TextEditingController pinController,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            Navigator.pop(ctx);

            final navigator = Navigator.of(context, rootNavigator: true);

            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dlgCtx) => AlertDialog(
                backgroundColor: Theme.of(dlgCtx).colorScheme.surface,
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red.shade800,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.finalConfirmation,
                      style: TextStyle(
                        color: Theme.of(dlgCtx).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  context.l10n.permanentDeleteAccountConfirm,
                  style: TextStyle(
                    color: Theme.of(dlgCtx).colorScheme.onSurface,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dlgCtx, false),
                    child: Text(
                      context.l10n.cancel,
                      style: TextStyle(
                        color: Theme.of(dlgCtx).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dlgCtx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(context.l10n.yesDelete),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              try {
                final userId = currentUser.id;
                await getIt<SettingsRepository>().deleteAllUserData(userId);
                await authRepository.deleteUser(userId);
                await authController.logout();

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (newCtx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        AppSnackBar.success(
                          newCtx,
                          context.l10n.profileAccountDeleted,
                        );
                      });
                      return LoginPage(authController: authController);
                    },
                  ),
                  (route) => false,
                );
              } catch (e) {
                if (context.mounted) {
                  AppSnackBar.error(
                    context,
                    context.l10n.accountDeleteFailed(e.toString()),
                  );
                }
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade800,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          context.l10n.deletePermanently,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // === Yardımcı Widget Builder'lar ===

  Widget _buildSheetHeader(BuildContext ctx, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(ctx).colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade800.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade800.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade800,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.thisActionIrreversibleWarning,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinField(
    BuildContext ctx,
    TextEditingController controller,
    String label,
    bool isVisible,
    VoidCallback onVisibilityToggle, {
    bool autofocus = false,
    Color? focusColor,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      obscureText: !isVisible,
      autofocus: autofocus,
      style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: focusColor ?? Theme.of(ctx).colorScheme.primary,
          ),
        ),
        filled: true,
        fillColor: Theme.of(ctx).colorScheme.surface,
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(BuildContext ctx, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(ctx).colorScheme.primary),
      ),
      filled: true,
      fillColor: Theme.of(ctx).colorScheme.surface,
    );
  }

  Widget _buildPrimaryButton(
    BuildContext ctx,
    String label,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(ctx).colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(
            ctx,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(ctx).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  ctx,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
