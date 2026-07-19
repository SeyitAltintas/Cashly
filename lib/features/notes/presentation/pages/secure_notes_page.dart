import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashly/core/widgets/app_snackbar.dart';
import 'package:cashly/features/notes/data/repositories/note_repository.dart';
import 'package:cashly/core/di/injection_container.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/note_card.dart';
import 'note_editor_page.dart';

class SecureNotesPage extends StatefulWidget {
  const SecureNotesPage({super.key});

  @override
  State<SecureNotesPage> createState() => _SecureNotesPageState();
}

class _SecureNotesPageState extends State<SecureNotesPage>
    with WidgetsBindingObserver {
  final NoteRepository _repository = getIt<NoteRepository>();
  bool _isUnlocked = false;
  bool _isCreatingPin = false;
  String _pin = '';
  String _firstPin = '';
  bool _isConfirmingPin = false;
  bool _isPinError = false;
  bool _isLoading = false;
  bool _isInitializing = true;

  final Set<String> _selectedNoteIds = {};
  StreamSubscription<BoxEvent>? _subscription;

  bool _isBiometricEnabled = false;
  bool _isAutoUnlock = false;
  bool _canUseBiometrics = false;

  static const platform = MethodChannel('com.seyitaltintas.cashly/security');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    try {
      platform.invokeMethod('secureScreenOn');
    } catch (_) {}
    _isCreatingPin = !_repository.hasSecurePin;
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    final canUse = await _repository.canUseBiometrics();
    final isBiometric = await _repository.isBiometricEnabled;
    final isAuto = await _repository.isAutoUnlockEnabled;

    if (mounted) {
      setState(() {
        _canUseBiometrics = canUse;
        _isBiometricEnabled = isBiometric;
        _isAutoUnlock = isAuto;
      });

      if (!_isCreatingPin && !_isUnlocked) {
        if (_isAutoUnlock) {
          _authenticateWithAuto();
        } else if (_isBiometricEnabled) {
          setState(() => _isInitializing = false);
          _authenticateWithBiometric();
        } else {
          setState(() => _isInitializing = false);
        }
      } else {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _authenticateWithAuto() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final success = await _repository.unlockWithAuto();
    if (mounted) {
      if (success) {
        setState(() {
          _isUnlocked = true;
          _isLoading = false;
          _isInitializing = false;
          _pin = '';
        });
        _startWatchingSecureNotes();
      } else {
        setState(() {
          _isLoading = false;
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final success = await _repository.unlockWithBiometric(
      'Gizli kasanızın kilidini açın',
    );
    if (mounted) {
      if (success) {
        setState(() {
          _isUnlocked = true;
          _isLoading = false;
          _pin = '';
        });
        _startWatchingSecureNotes();
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    try {
      platform.invokeMethod('secureScreenOff');
    } catch (_) {}
    
    _subscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _repository.closeSecureNotes();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_repository.isMediaPicking) {
        return; // EC-EDGE: Kamera/Galeri açıksa kilitleme
      }

      // Lock on app pause / background
      _subscription?.cancel();
      _subscription = null;
      _repository.closeSecureNotes();
      if (mounted) {
        setState(() {
          _isUnlocked = false;
          _pin = '';
          _isConfirmingPin = false;
          _firstPin = '';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gizli Kasayı Sıfırla'),
        content: const Text(
          'Şifrenizi (PIN) unuttuysanız, gizli kasanızı sıfırlayabilirsiniz.\n\n'
          'DİKKAT: Bu işlem içerideki tüm gizli notlarınızı ve medyalarınızı KALICI OLARAK SİLER. '
          'Bunu onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Evet, Her Şeyi Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _repository.resetSecureKasa();
      if (mounted) {
        setState(() {
          _isUnlocked = false;
          _isCreatingPin = true;
          _pin = '';
          _firstPin = '';
          _isConfirmingPin = false;
          _isLoading = false;
        });
        AppSnackBar.success(
          context,
          'Kasa sıfırlandı. Lütfen yeni bir PIN oluşturun.',
        );
      }
    }
  }

  void _onKeyPress(String key) {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isPinError = false;
      if (key == 'back') {
        if (_pin.isNotEmpty) {
          _pin = _pin.substring(0, _pin.length - 1);
        }
      } else {
        if (_pin.length < 4) {
          _pin += key;
        }
      }
    });

    if (_pin.length == 4) {
      _submitPin();
    }
  }

  Future<void> _submitPin() async {
    setState(() => _isLoading = true);
    if (_isCreatingPin) {
      if (!_isConfirmingPin) {
        setState(() {
          _firstPin = _pin;
          _pin = '';
          _isConfirmingPin = true;
          _isLoading = false;
        });
      } else {
        if (_pin == _firstPin) {
          await _repository.setSecurePin(_pin);

          if (mounted && _canUseBiometrics) {
            final wantBiometric = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                title: const Text('Biyometrik Giriş'),
                content: const Text(
                  'Gizli kasanıza daha hızlı erişmek için yüz tanıma veya parmak izi kullanmak ister misiniz?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Hayır'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text('Evet, Kullan'),
                  ),
                ],
              ),
            );
            if (wantBiometric == true) {
              await _repository.enableBiometric(_pin);
              _isBiometricEnabled = true;
            }
          }

          if (mounted) {
            setState(() {
              _isCreatingPin = false;
              _isUnlocked = true;
              _isLoading = false;
              _pin = '';
            });
            _startWatchingSecureNotes();
            AppSnackBar.success(
              context,
              'Güvenlik PIN\'i başarıyla oluşturuldu.',
            );
          }
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _pin = '';
            _isPinError = true;
            _isLoading = false;
          });
          if (mounted) {
            AppSnackBar.error(
              context,
              'PIN kodları eşleşmedi. Tekrar deneyin.',
            );
          }
        }
      }
    } else {
      final success = await _repository.unlockSecureNotes(_pin);
      if (mounted) {
        if (success) {
          setState(() {
            _isUnlocked = true;
            _isLoading = false;
            _pin = '';
          });
          _startWatchingSecureNotes();
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _pin = '';
            _isPinError = true;
            _isLoading = false;
          });
        }
      }
    }
  }

  void _startWatchingSecureNotes() {
    _subscription?.cancel();
    _subscription = _repository.watchSecure()?.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _openNote(String? id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(
          noteId: id,
          heroTag: id != null ? 'note_hero_$id' : 'note_hero_new_secure',
          isSecure: true,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedNoteIds.contains(id)) {
        _selectedNoteIds.remove(id);
      } else {
        _selectedNoteIds.add(id);
      }
    });
  }

  Future<void> _unsecureSelected() async {
    if (_selectedNoteIds.isEmpty) return;
    final ids = _selectedNoteIds.toList();
    setState(() {
      _selectedNoteIds.clear();
    });
    await _repository.unsecureNotes(ids);
    if (mounted) {
      AppSnackBar.success(context, 'Seçilen notların kilidi kaldırıldı.');
    }
  }

  Future<void> _confirmDeleteSelected() async {
    final count = _selectedNoteIds.length;
    if (count == 0) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kalıcı Olarak Sil'),
        content: Text(
          '$count adet güvenli not kalıcı olarak silinecektir. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ids = _selectedNoteIds.toList();
      setState(() {
        _selectedNoteIds.clear();
      });
      await _repository.permanentlyDeleteSecureNotes(ids);
      if (mounted) {
        AppSnackBar.success(context, 'Notlar kalıcı olarak silindi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isInitializing) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isUnlocked) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 320),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isPinError
                        ? colorScheme.errorContainer.withValues(alpha: 0.2)
                        : colorScheme.primaryContainer.withValues(alpha: 0.2),
                  ),
                  child: Icon(
                    _isPinError
                        ? Icons.lock_open_rounded
                        : Icons.lock_outline_rounded,
                    color: _isPinError
                        ? colorScheme.error
                        : colorScheme.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isCreatingPin
                      ? (_isConfirmingPin
                            ? 'PIN Kodunu Doğrula'
                            : 'Yeni PIN Kodu Belirle')
                      : 'Gizli Bölge',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isPinError
                      ? 'Hatalı PIN. Tekrar deneyin.'
                      : (_isCreatingPin && !_isConfirmingPin
                            ? 'Gizli notlarınızı şifrelemek için 4 haneli kod belirleyin'
                            : 'Güvenli notlarınıza erişmek için PIN kodunuzu girin'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: _isPinError
                        ? colorScheme.error
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 32),
                // Pin dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final hasChar = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isPinError
                            ? (hasChar ? colorScheme.error : Colors.transparent)
                            : (hasChar
                                  ? colorScheme.primary
                                  : Colors.transparent),
                        border: Border.all(
                          color: _isPinError
                              ? colorScheme.error
                              : (hasChar
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withValues(
                                        alpha: 0.2,
                                      )),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),
                // Keypad
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey('1'),
                        _buildKey('2'),
                        _buildKey('3'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey('4'),
                        _buildKey('5'),
                        _buildKey('6'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildKey('7'),
                        _buildKey('8'),
                        _buildKey('9'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _isBiometricEnabled && !_isCreatingPin
                            ? _buildKey('biometric', isIcon: true)
                            : const SizedBox(width: 64, height: 64),
                        _buildKey('0'),
                        _buildKey('back', isIcon: true),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (!_isCreatingPin)
                  TextButton(
                    onPressed: _showResetDialog,
                    child: Text(
                      'Şifremi Unuttum',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final secureNotes = _repository.getSecureNotes();
    final isSelectionMode = _selectedNoteIds.isNotEmpty;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => setState(() => _selectedNoteIds.clear()),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          isSelectionMode
              ? '${_selectedNoteIds.length} Seçildi'
              : 'Gizli Notlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: Icon(
                _selectedNoteIds.length == secureNotes.length
                    ? Icons.deselect_rounded
                    : Icons.select_all_rounded,
              ),
              onPressed: () {
                setState(() {
                  if (_selectedNoteIds.length == secureNotes.length) {
                    _selectedNoteIds.clear();
                  } else {
                    _selectedNoteIds.addAll(secureNotes.map((n) => n.id));
                  }
                });
              },
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: 'Kasa Ayarları',
                  onPressed: _showSettingsBottomSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.lock_rounded),
                  onPressed: () {
                    _repository.closeSecureNotes();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
        ],
      ),
      body: secureNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 64,
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gizli Not Yok',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Yeni not ekleyebilir veya ana sayfadan notları buraya kilitleyebilirsiniz.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: MasonryGridView.builder(
                gridDelegate:
                    const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemCount: secureNotes.length,
                itemBuilder: (context, index) {
                  final note = secureNotes[index];
                  final isSelected = _selectedNoteIds.contains(note.id);
                  return NoteCard(
                    note: note,
                    isGrid: true,
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(note.id);
                      } else {
                        _openNote(note.id);
                      }
                    },
                    onLongPress: () => _toggleSelection(note.id),
                  );
                },
              ),
            ),
      bottomNavigationBar: isSelectionMode
          ? Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.paddingOf(context).bottom + 12,
                top: 12,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionBarButton(
                    icon: Icons.lock_open_rounded,
                    label: 'Kilidi Aç',
                    color: colorScheme.primary,
                    onTap: _unsecureSelected,
                  ),
                  _buildActionBarButton(
                    icon: Icons.delete_forever_rounded,
                    label: 'Kalıcı Sil',
                    color: Colors.red,
                    onTap: _confirmDeleteSelected,
                  ),
                ],
              ),
            )
          : null,
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
              onPressed: () => _openNote(null),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildActionBarButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SettingsBottomSheet(
        repository: _repository,
        canUseBiometrics: _canUseBiometrics,
        isBiometricEnabled: _isBiometricEnabled,
        isAutoUnlock: _isAutoUnlock,
        onSettingsChanged: _checkBiometricStatus,
      ),
    );
  }

  Widget _buildKey(String val, {bool isIcon = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (val == 'biometric') {
            _authenticateWithBiometric();
          } else {
            _onKeyPress(val);
          }
        },
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
          child: Center(
            child: isIcon
                ? Icon(
                    val == 'biometric'
                        ? Icons.fingerprint_rounded
                        : Icons.backspace_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: val == 'biometric' ? 28 : 20,
                  )
                : Text(
                    val,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SettingsBottomSheet extends StatefulWidget {
  final NoteRepository repository;
  final bool canUseBiometrics;
  final bool isBiometricEnabled;
  final bool isAutoUnlock;
  final VoidCallback onSettingsChanged;

  const _SettingsBottomSheet({
    required this.repository,
    required this.canUseBiometrics,
    required this.isBiometricEnabled,
    required this.isAutoUnlock,
    required this.onSettingsChanged,
  });

  @override
  State<_SettingsBottomSheet> createState() => _SettingsBottomSheetState();
}

class _SettingsBottomSheetState extends State<_SettingsBottomSheet> {
  late bool _biometric;
  late bool _autoUnlock;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _biometric = widget.isBiometricEnabled;
    _autoUnlock = widget.isAutoUnlock;
  }

  Future<void> _toggleBiometric(bool val) async {
    if (val) {
      final pin = await _askForPin('Biyometrik Girişi Aç');
      if (pin != null) {
        // EDGE CASE FIX: Doğru şifre girilmezse kabul etme
        final isValid = await widget.repository.unlockSecureNotes(pin);
        if (!isValid) {
          if (mounted) AppSnackBar.error(context, 'Hatalı şifre.');
          return;
        }
        await widget.repository.enableBiometric(pin);
        setState(() => _biometric = true);
        widget.onSettingsChanged();
      }
    } else {
      await widget.repository.disableBiometric();
      setState(() => _biometric = false);
      widget.onSettingsChanged();
    }
  }

  Future<void> _toggleAutoUnlock(bool val) async {
    if (val) {
      final pin = await _askForPin('Şifresiz Girişi Aç');
      if (pin != null) {
        // EDGE CASE FIX: Doğru şifre girilmezse kabul etme
        final isValid = await widget.repository.unlockSecureNotes(pin);
        if (!isValid) {
          if (mounted) AppSnackBar.error(context, 'Hatalı şifre.');
          return;
        }
        await widget.repository.enableAutoUnlock(pin);
        setState(() => _autoUnlock = true);
        widget.onSettingsChanged();
      }
    } else {
      await widget.repository.disableAutoUnlock();
      setState(() => _autoUnlock = false);
      widget.onSettingsChanged();
    }
  }

  Future<String?> _askForPin(String title) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => _PinInputDialog(title: title),
    );
  }

  Future<void> _changePin() async {
    final currentPin = await _askForPin('Mevcut Şifrenizi Girin');
    if (currentPin == null) return;

    final success = await widget.repository.unlockSecureNotes(currentPin);
    if (!success) {
      if (mounted) AppSnackBar.error(context, 'Hatalı şifre girdiniz.');
      return;
    }

    if (!mounted) return;
    final newPin1 = await _askForPin('Yeni Şifre Belirleyin');
    if (newPin1 == null || newPin1.length != 4) return;

    if (!mounted) return;
    final newPin2 = await _askForPin('Yeni Şifreyi Tekrar Girin');
    if (newPin2 == null || newPin2 != newPin1) {
      if (mounted) AppSnackBar.error(context, 'Şifreler eşleşmedi.');
      return;
    }

    setState(() => _isLoading = true);

    final migrated = await widget.repository.changeSecurePin(
      currentPin,
      newPin1,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (migrated) {
        AppSnackBar.success(context, 'Kasa şifreniz başarıyla değiştirildi.');
        widget.onSettingsChanged();
        Navigator.of(context).pop();
      } else {
        AppSnackBar.error(context, 'Şifre değiştirilirken bir hata oluştu.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kasa Ayarları',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Veriler yeni şifreye aktarılıyor, lütfen bekleyin...',
                  textAlign: TextAlign.center,
                ),
              ),
            ] else ...[
              if (widget.canUseBiometrics)
                SwitchListTile(
                  title: const Text(
                    'Biyometrik Giriş',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Kasanıza yüzünüz veya parmak izinizle erişin',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _biometric,
                  activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: colorScheme.primary,
                  onChanged: _toggleBiometric,
                  contentPadding: EdgeInsets.zero,
                ),
              SwitchListTile(
                title: const Text(
                  'Şifre Sorma (Otomatik Giriş)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Kasaya girerken şifre girmeden direkt açılır',
                  style: TextStyle(fontSize: 12),
                ),
                value: _autoUnlock,
                activeTrackColor: colorScheme.primary.withValues(alpha: 0.5),
                activeThumbColor: colorScheme.primary,
                onChanged: _toggleAutoUnlock,
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.password_rounded),
                title: const Text(
                  'Şifreyi Değiştir',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Kasa PIN kodunuzu yenileyin',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: _changePin,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PinInputDialog extends StatefulWidget {
  final String title;
  const _PinInputDialog({required this.title});

  @override
  State<_PinInputDialog> createState() => _PinInputDialogState();
}

class _PinInputDialogState extends State<_PinInputDialog> {
  String _pin = '';

  void _onKeyPress(String key) {
    setState(() {
      if (key == 'back') {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      } else {
        if (_pin.length < 4) _pin += key;
      }
    });

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.of(context).pop(_pin);
      });
    }
  }

  Widget _buildKey(String val, {bool isIcon = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKeyPress(val),
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
          ),
          child: Center(
            child: isIcon
                ? Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  )
                : Text(
                    val,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final hasChar = index < _pin.length;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasChar
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildKey('1'), _buildKey('2'), _buildKey('3')],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildKey('4'), _buildKey('5'), _buildKey('6')],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildKey('7'), _buildKey('8'), _buildKey('9')],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 56, height: 56),
                _buildKey('0'),
                _buildKey('back', isIcon: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
