import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../auth/domain/entities/user_entity.dart';

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

  ImageProvider? _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    } else if (path.startsWith('lib/') || path.startsWith('assets/')) {
      return AssetImage(path);
    } else {
      return FileImage(File(path));
    }
  }

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
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    image: user.profileImage != null
                        ? DecorationImage(
                            image: _getImageProvider(user.profileImage!)!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.profileImage == null
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
                  onTap: onEditTap,
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
        Divider(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          thickness: 2,
          indent: 40,
          endIndent: 40,
        ),
      ],
    );
  }
}
