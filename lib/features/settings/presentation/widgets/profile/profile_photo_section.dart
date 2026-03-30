import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../../core/utils/image_utils.dart';

/// Profil fotoğrafı bölümü widget'ı
/// Profil resmini gösterir ve düzenleme butonu içerir
class ProfilePhotoSection extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onPhotoTap;
  final VoidCallback onEditTap;

  const ProfilePhotoSection({
    super.key,
    required this.user,
    required this.onPhotoTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: onPhotoTap,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      // Gri-beyaz çerçeve rengi
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(child: _buildProfileImage(context)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                      // Beyaza yakın gri border
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
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
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          thickness: 2,
          indent: 40,
          endIndent: 40,
        ),
      ],
    );
  }

  /// Profil resmini oluştur - error handling ile
  Widget _buildProfileImage(BuildContext context) {
    if (user.profileImage == null) {
      return _buildDefaultIcon(context);
    }

    return Image(
      image: ImageUtils.getProfileImageProvider(user.profileImage!),
      fit: BoxFit.cover,
      width: 120,
      height: 120,
      errorBuilder: (context, error, stackTrace) => _buildDefaultIcon(context),
    );
  }

  /// Varsayılan profil ikonu
  Widget _buildDefaultIcon(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      color: Theme.of(context).colorScheme.surface,
      child: Icon(
        Icons.person,
        size: 60,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
