import 'dart:async';
import 'package:flutter/material.dart';
import '../services/network_service.dart';

/// Çevrimdışı durumda görünen kompakt network status ikonu
/// Dashboard'da streak widget'ının solunda gösterilir
/// Tıklandığında detaylı bilgi modalı açar
/// Bağlantı geldiğinde yeşil ikon 3 saniye gösterilir
class NetworkStatusIcon extends StatefulWidget {
  const NetworkStatusIcon({super.key});

  @override
  State<NetworkStatusIcon> createState() => _NetworkStatusIconState();
}

class _NetworkStatusIconState extends State<NetworkStatusIcon> {
  final NetworkService _networkService = NetworkService();

  bool _wasOffline = false;
  bool _showConnectedIcon = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _networkService.addListener(_onNetworkChange);
    _wasOffline = _networkService.isOffline;
  }

  @override
  void dispose() {
    _networkService.removeListener(_onNetworkChange);
    _hideTimer?.cancel();
    super.dispose();
  }

  void _onNetworkChange() {
    final isOffline = _networkService.isOffline;

    if (!isOffline && _wasOffline) {
      // Çevrimdışıdan çevrimiçi oldu - yeşil ikon göster
      setState(() {
        _showConnectedIcon = true;
      });

      // 3 saniye sonra gizle
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showConnectedIcon = false;
          });
        }
      });
    }

    _wasOffline = isOffline;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isOffline = _networkService.isOffline;

    // Çevrimiçi ve bağlantı yeni geldi - yeşil ikon göster
    if (!isOffline && _showConnectedIcon) {
      return _buildConnectedIcon();
    }

    // Çevrimdışı - kırmızı ikon göster
    if (isOffline) {
      return _buildOfflineIcon(context);
    }

    // Çevrimiçi ve normal durum - gizle
    return const SizedBox.shrink();
  }

  Widget _buildConnectedIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.wifi_rounded,
              color: Colors.green.shade300,
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOfflineIcon(BuildContext context) {
    return GestureDetector(
      onTap: () => _showOfflineInfoDialog(context),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.6, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: value * 0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: value * 0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: Colors.red.shade300,
              size: 20,
            ),
          );
        },
        onEnd: () {
          // Animasyonu tekrarla
        },
      ),
    );
  }

  /// Çevrimdışı mod hakkında bilgi veren modal dialog
  void _showOfflineInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.shade900.withValues(alpha: 0.5),
                      Colors.red.shade800.withValues(alpha: 0.3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Çevrimdışı Mod',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'İnternet bağlantısı yok',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // İçerik
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Çalışmayan özellikler
                    _buildSection(
                      icon: Icons.cancel_rounded,
                      iconColor: Colors.red,
                      title: 'Çalışmayan Özellikler',
                      items: [
                        'Varlık fiyat güncellemeleri',
                        'Gerçek zamanlı döviz kurları',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Eksik çalışan özellikler
                    _buildSection(
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                      title: 'Kısıtlı Özellikler',
                      items: [
                        'Varlık değerleri son bilinen fiyatlarla gösterilir',
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tam çalışan özellikler
                    _buildSection(
                      icon: Icons.check_circle_rounded,
                      iconColor: Colors.green,
                      title: 'Tam Çalışan Özellikler',
                      items: [
                        'Gelir/gider ekleme ve düzenleme',
                        'Yedekleme ve geri yükleme',
                        'Grafikler ve raporlar',
                        'Tüm yerel veriler',
                      ],
                    ),
                  ],
                ),
              ),

              // Kapat butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                    ),
                    child: const Text(
                      'Anladım',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<String> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: iconColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 26, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '•',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
