import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../../auth/presentation/pages/login_page.dart';
import '../../../../../services/database_helper.dart';

/// Profil ayarları dialog/sheet yardımcı sınıfı
/// Avatar seçimi, isim değiştirme, PIN değiştirme, hesap silme akışlarını yönetir
class ProfileSettingsHelper {
  final BuildContext context;
  final AuthController authController;
  final UserEntity currentUser;
  final AuthRepositoryImpl authRepository;
  final VoidCallback onUserUpdated;
  final List<String> profileImageUrls;

  ProfileSettingsHelper({
    required this.context,
    required this.authController,
    required this.currentUser,
    required this.authRepository,
    required this.onUserUpdated,
    required this.profileImageUrls,
  });

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  List<String> _getRandomImages() {
    final random = Random();
    final List<String> shuffled = List.from(profileImageUrls)..shuffle(random);
    return shuffled.take(9).toList();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage ?? "Profil güncellendi"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Güncelleme başarısız: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _updateUser(
        profileImage: image.path,
        successMessage: "Profil resmi güncellendi",
      );
      if (context.mounted) Navigator.pop(context);
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

  /// Avatar seçim dialog'u
  void showAvatarSelectionDialog() {
    List<String> displayedImages = _getRandomImages();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateBottomSheet) {
          return Container(
            height: MediaQuery.of(ctx).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSheetHeader(ctx, "Profil Resmi Seç"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galeriden Seç"),
                        style: _outlinedButtonStyle(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setStateBottomSheet(() {
                            displayedImages = _getRandomImages();
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Resimleri Yenile"),
                        style: _outlinedButtonStyle(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: displayedImages.length,
                    itemBuilder: (ctx, index) {
                      final imagePath = displayedImages[index];
                      return GestureDetector(
                        onTap: () {
                          _updateUser(
                            profileImage: imagePath,
                            successMessage: "Profil resmi güncellendi",
                          );
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                ctx,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image(
                              image: _getImageProvider(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
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
              _buildSheetHeader(ctx, "İsim Değiştir"),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
                  decoration: _inputDecoration(ctx, "Yeni İsim"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "İsim boş olamaz";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              _buildPrimaryButton(ctx, "Kaydet", () {
                if (formKey.currentState!.validate()) {
                  _updateUser(
                    name: nameController.text.trim(),
                    successMessage: "İsim Soyisim Güncellendi",
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
                  _buildSheetHeader(ctx, step == 1 ? "Mevcut PIN" : "Yeni PIN"),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        if (step == 1)
                          _buildPinField(
                            ctx,
                            currentPinController,
                            "Mevcut PIN",
                            isCurrentPinVisible,
                            () => setStateBottomSheet(
                              () => isCurrentPinVisible = !isCurrentPinVisible,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length < 4 ||
                                  value.length > 6) {
                                return "4-6 haneli PIN giriniz";
                              }
                              if (value != currentUser.pin) {
                                return "PIN hatalı";
                              }
                              return null;
                            },
                          ),
                        if (step == 2) ...[
                          _buildPinField(
                            ctx,
                            newPinController,
                            "Yeni PIN",
                            isNewPinVisible,
                            () => setStateBottomSheet(
                              () => isNewPinVisible = !isNewPinVisible,
                            ),
                            autofocus: true,
                            validator: (value) {
                              if (value == null ||
                                  value.length < 4 ||
                                  value.length > 6) {
                                return "4-6 haneli PIN giriniz";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildPinField(
                            ctx,
                            confirmPinController,
                            "Yeni PIN (Tekrar)",
                            isConfirmPinVisible,
                            () => setStateBottomSheet(
                              () => isConfirmPinVisible = !isConfirmPinVisible,
                            ),
                            validator: (value) {
                              if (value != newPinController.text) {
                                return "PIN'ler eşleşmiyor";
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPrimaryButton(ctx, step == 1 ? "İleri" : "Kaydet", () {
                    if (formKey.currentState!.validate()) {
                      if (step == 1) {
                        setStateBottomSheet(() => step = 2);
                      } else {
                        _updateUser(
                          pin: newPinController.text,
                          successMessage: "PIN Güncellendi",
                        );
                        Navigator.pop(ctx);
                      }
                    }
                  }),
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
                  _buildSheetHeader(ctx, "PIN Doğrulama"),
                  const SizedBox(height: 8),
                  Text(
                    "Biyometrik girişi aktifleştirmek için PIN'inizi doğrulayın",
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
                          return "4-6 haneli PIN giriniz";
                        }
                        if (value != currentUser.pin) {
                          return "PIN hatalı";
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
                      label: const Text(
                        "Biyometriği Aktifleştir",
                        style: TextStyle(
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
                        "Hesabı Sil",
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
                      "PIN Doğrulaması",
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
                          return "4-6 haneli PIN giriniz";
                        }
                        if (value != currentUser.pin) {
                          return "PIN hatalı";
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
            final scaffoldMessenger = ScaffoldMessenger.of(context);

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
                      "Son Onay",
                      style: TextStyle(
                        color: Theme.of(dlgCtx).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  "Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?",
                  style: TextStyle(
                    color: Theme.of(dlgCtx).colorScheme.onSurface,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dlgCtx, false),
                    child: Text(
                      "İptal",
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
                    child: const Text("Evet, Sil"),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              try {
                final userId = currentUser.id;
                await DatabaseHelper.deleteUserData(userId);
                await authRepository.deleteUser(userId);
                await authController.logout();

                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (newCtx) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(newCtx).showSnackBar(
                          const SnackBar(
                            content: Text("Hesabınız başarıyla silindi"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                      return LoginPage(authController: authController);
                    },
                  ),
                  (route) => false,
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text("Hesap silinirken hata oluştu: $e"),
                    backgroundColor: Colors.red.shade800,
                  ),
                );
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
        child: const Text(
          "Hesabı Kalıcı Olarak Sil",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              "Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir.",
              style: TextStyle(
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

  ButtonStyle _outlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
}
