import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../services/database_helper.dart';
import '../../../../services/biometric_service.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/presentation/pages/login_page.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

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

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('lib/') || path.startsWith('assets/')) {
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
    if (_currentUser == null) return;

    final updatedUser = UserEntity(
      id: _currentUser!.id,
      name: name ?? _currentUser!.name,
      email: _currentUser!.email,
      pin: pin ?? _currentUser!.pin,
      profileImage: profileImage ?? _currentUser!.profileImage,
      createdAt: _currentUser!.createdAt,
      lastLoginAt: _currentUser!.lastLoginAt,
      biometricEnabled: _currentUser!.biometricEnabled,
    );

    try {
      await _authRepository.updateUser(updatedUser);
      await widget.authController.checkAuth();
      setState(() {
        _currentUser = widget.authController.currentUser;
      });
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(
          context,
          successMessage ?? "Profil güncellendi",
        );
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, "Güncelleme başarısız: $e");
      }
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

  Future<void> _handleBiometricToggle(bool enabled) async {
    if (_currentUser == null) return;

    if (enabled) {
      // Biyometrik aktifleştirmek için önce PIN doğrulama iste
      _showPinVerificationForBiometric();
    } else {
      // Biyometrik kapatma - doğrudan kapat
      await widget.authController.setBiometricEnabled(_currentUser!.id, false);
      setState(() {
        _currentUser = widget.authController.currentUser;
      });
      if (mounted) {
        ErrorHandler.showSuccessSnackBar(context, "Biyometrik giriş kapatıldı");
      }
    }
  }

  void _showPinVerificationForBiometric() {
    final TextEditingController pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                        "PIN Doğrulama",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Biyometrik girişi aktifleştirmek için PIN'inizi doğrulayın",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: !isPinVisible,
                      autofocus: true,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: "PIN",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPinVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setStateBottomSheet(() {
                              isPinVisible = !isPinVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 6) {
                          return "4-6 haneli PIN giriniz";
                        }
                        if (value != _currentUser!.pin) {
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
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final navigator = Navigator.of(context);
                          await widget.authController.setBiometricEnabled(
                            _currentUser!.id,
                            true,
                          );
                          navigator.pop();
                          if (mounted) {
                            setState(() {
                              _currentUser = widget.authController.currentUser;
                            });
                            ErrorHandler.showSuccessSnackBar(
                              this.context,
                              "Biyometrik giriş aktifleştirildi",
                            );
                          }
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
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

  List<String> _getRandomImages() {
    final random = Random();
    final List<String> shuffled = List.from(_profileImageUrls)..shuffle(random);
    return shuffled.take(9).toList();
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d MMMM yyyy, HH:mm', 'tr_TR');
    return formatter.format(date);
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _updateUser(
        profileImage: image.path,
        successMessage: "Profil resmi güncellendi",
      );
      if (mounted) Navigator.pop(context);
    }
  }

  void _showAvatarSelectionDialog() {
    List<String> displayedImages = _getRandomImages();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Profil Resmi Seç",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickImageFromGallery,
                        icon: const Icon(Icons.photo_library),
                        label: const Text("Galeriden Seç"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
                    itemBuilder: (context, index) {
                      final imagePath = displayedImages[index];

                      return GestureDetector(
                        onTap: () {
                          _updateUser(
                            profileImage: imagePath,
                            successMessage: "Profil resmi güncellendi",
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image(
                              image: _getImageProvider(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
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

  void _showFullScreenImage() {
    if (_currentUser?.profileImage == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(alpha: 0.8),
              ),
            ),
            InteractiveViewer(
              child: Image(
                image: _getImageProvider(_currentUser!.profileImage!),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNameChangeBottomSheet() {
    if (_currentUser == null) return;
    final TextEditingController nameController = TextEditingController(
      text: _currentUser!.name,
    );
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    "İsim Değiştir",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: "Yeni İsim",
                    labelStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "İsim boş olamaz";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      _updateUser(
                        name: nameController.text.trim(),
                        successMessage: "İsim Soyisim Güncellendi",
                      );
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Kaydet",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showPinChangeBottomSheet() {
    if (_currentUser == null) return;
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
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                        step == 1 ? "Mevcut PIN" : "Yeni PIN",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        if (step == 1)
                          TextFormField(
                            controller: currentPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: !isCurrentPinVisible,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: "Mevcut PIN",
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isCurrentPinVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    isCurrentPinVisible = !isCurrentPinVisible;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.length < 4 ||
                                  value.length > 6) {
                                return "4-6 haneli PIN giriniz";
                              }
                              if (value != _currentUser!.pin) {
                                return "PIN hatalı";
                              }
                              return null;
                            },
                          ),
                        if (step == 2) ...[
                          TextFormField(
                            controller: newPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: !isNewPinVisible,
                            autofocus: true,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: "Yeni PIN",
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isNewPinVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    isNewPinVisible = !isNewPinVisible;
                                  });
                                },
                              ),
                            ),
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
                          TextFormField(
                            controller: confirmPinController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            obscureText: !isConfirmPinVisible,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              labelText: "Yeni PIN (Tekrar)",
                              labelStyle: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context).colorScheme.surface,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isConfirmPinVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                                onPressed: () {
                                  setStateBottomSheet(() {
                                    isConfirmPinVisible = !isConfirmPinVisible;
                                  });
                                },
                              ),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (step == 1) {
                            setStateBottomSheet(() {
                              step = 2;
                            });
                          } else {
                            _updateUser(
                              pin: newPinController.text,
                              successMessage: "PIN Güncellendi",
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        step == 1 ? "İleri" : "Kaydet",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  void _showDeleteAccountDialog() {
    if (_currentUser == null) return;
    final TextEditingController pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isPinVisible = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Bu işlem geri alınamaz! Tüm verileriniz kalıcı olarak silinecektir.",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: !isPinVisible,
                      autofocus: true,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: "PIN Doğrulaması",
                        labelStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.2),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPinVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            setStateBottomSheet(() {
                              isPinVisible = !isPinVisible;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.length < 4 ||
                            value.length > 6) {
                          return "4-6 haneli PIN giriniz";
                        }
                        if (value != _currentUser!.pin) {
                          return "PIN hatalı";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);

                          // Capture navigator BEFORE showing dialog (while context is still valid)
                          final navigator = Navigator.of(
                            context,
                            rootNavigator: true,
                          );
                          final scaffoldMessenger = ScaffoldMessenger.of(
                            context,
                          );

                          // Final confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surface,
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Son Onay",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                "Hesabınızı kalıcı olarak silmek istediğinizden emin misiniz?",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("İptal"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Evet, Sil"),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            try {
                              final userId = _currentUser!.id;
                              debugPrint(
                                '🗑️ Starting account deletion for user: $userId',
                              );

                              // Delete user data
                              await DatabaseHelper.deleteUserData(userId);
                              debugPrint('✅ User data deleted');

                              // Delete user account
                              await _authRepository.deleteUser(userId);
                              debugPrint('✅ User account deleted');

                              // Logout
                              await widget.authController.logout();
                              debugPrint('✅ Logout completed');

                              // Navigate to login page using captured navigator
                              debugPrint('🔄 Navigating to LoginPage...');
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (newContext) {
                                    debugPrint('📱 Building LoginPage');
                                    // Show success message after login page is built
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          ScaffoldMessenger.of(
                                            newContext,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Hesabınız başarıyla silindi",
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        });
                                    return LoginPage(
                                      authController: widget.authController,
                                    );
                                  },
                                ),
                                (route) => false,
                              );
                              debugPrint('✅ Navigation completed');
                            } catch (e, stackTrace) {
                              debugPrint('❌ Error during account deletion: $e');
                              debugPrint('Stack trace: $stackTrace');
                              // Use captured scaffoldMessenger instead of context
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Hesap silinirken hata oluştu: $e",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Hesabı Kalıcı Olarak Sil",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
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
            // Profil Resmi
            SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _showFullScreenImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        image: _currentUser!.profileImage != null
                            ? DecorationImage(
                                image: _getImageProvider(
                                  _currentUser!.profileImage!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _currentUser!.profileImage == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.onSurface,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showAvatarSelectionDialog,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Silik çizgi
            Divider(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              thickness: 2,
              indent: 40,
              endIndent: 40,
            ),
            const SizedBox(height: 24),

            // İsim Değiştirme Kartı
            _buildSettingsCard(
              context,
              title: "İsim Soyisim",
              subtitle: _currentUser!.name,
              icon: Icons.person_outline,
              onTap: _showNameChangeBottomSheet,
            ),
            const SizedBox(height: 16),

            // E-posta (Değiştirilemez)
            _buildSettingsCard(
              context,
              title: "E-posta",
              subtitle: _currentUser!.email,
              icon: Icons.email_outlined,
              onTap: null,
            ),
            const SizedBox(height: 16),

            // PIN Değiştirme
            _buildSettingsCard(
              context,
              title: "Güvenlik PIN'i",
              subtitle: "****",
              icon: Icons.lock_outline,
              onTap: _showPinChangeBottomSheet,
            ),
            const SizedBox(height: 16),

            // Biyometrik Giriş
            if (_isBiometricAvailable)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    "Biyometrik Giriş",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Parmak izi veya yüz tanıma ile giriş",
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Switch(
                    value: _currentUser?.biometricEnabled ?? false,
                    onChanged: _handleBiometricToggle,
                    activeTrackColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),

            // Hesap Oluşturulma Tarihi
            _buildSettingsCard(
              context,
              title: "Hesap Oluşturulma Tarihi",
              subtitle: _formatDate(_currentUser!.createdAt),
              icon: Icons.calendar_today_outlined,
              onTap: null,
            ),
            const SizedBox(height: 16),

            // Son Giriş Tarihi
            _buildSettingsCard(
              context,
              title: "Son Giriş Tarihi",
              subtitle: _currentUser!.lastLoginAt != null
                  ? _formatDate(_currentUser!.lastLoginAt!)
                  : "Bilinmiyor",
              icon: Icons.login_outlined,
              onTap: null,
            ),
            const SizedBox(height: 40),

            // Tehlikeli Bölge
            Text(
              "Tehlikeli Bölge",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),

            // Hesabı Sil
            Card(
              color: Colors.red.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_forever, color: Colors.red),
                ),
                title: Text(
                  "Hesabı Sil",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  "Hesabınızı ve tüm verilerinizi kalıcı olarak silin",
                  style: TextStyle(color: Colors.red.withValues(alpha: 0.7)),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                onTap: _showDeleteAccountDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.secondary),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        trailing: onTap != null
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
