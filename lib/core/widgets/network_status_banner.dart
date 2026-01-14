import 'package:flutter/material.dart';
import '../services/network_service.dart';

/// Network durumu değişikliklerini dinleyen ve UI'da gösteren widget
///
/// Bu widget, network durumu değiştiğinde otomatik olarak bir banner gösterir
/// ve kullanıcıyı bilgilendirir.
///
/// Kullanım:
/// ```dart
/// NetworkStatusBanner(
///   child: YourMainContent(),
/// )
/// ```
class NetworkStatusBanner extends StatefulWidget {
  /// Alt içerik widget'ı
  final Widget child;

  /// Offline banner'ın gösterileceği pozisyon
  final bool showAtTop;

  /// Banner animasyon süresi
  final Duration animationDuration;

  const NetworkStatusBanner({
    super.key,
    required this.child,
    this.showAtTop = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner>
    with SingleTickerProviderStateMixin {
  final NetworkService _networkService = NetworkService();

  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _showBanner = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation =
        Tween<double>(begin: widget.showAtTop ? -1.0 : 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Network durumunu dinle
    _networkService.addListener(_onNetworkChange);

    // İlk durumu kontrol et
    _checkInitialStatus();
  }

  void _checkInitialStatus() {
    if (_networkService.isOffline) {
      setState(() {
        _showBanner = true;
        _wasOffline = true;
      });
      _animationController.forward();
    }
  }

  void _onNetworkChange() {
    final isOffline = _networkService.isOffline;

    if (isOffline && !_showBanner) {
      // Offline oldu - banner göster
      setState(() {
        _showBanner = true;
        _wasOffline = true;
      });
      _animationController.forward();
    } else if (!isOffline && _wasOffline) {
      // Tekrar online oldu - kısa süre "bağlandı" mesajı göster
      setState(() {});
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _networkService.isOnline) {
          _animationController.reverse().then((_) {
            if (mounted) {
              setState(() {
                _showBanner = false;
                _wasOffline = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _networkService.removeListener(_onNetworkChange);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Ana içerik
        widget.child,

        // Network banner
        if (_showBanner)
          Positioned(
            top: widget.showAtTop ? 0 : null,
            bottom: widget.showAtTop ? null : 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value * 60),
                  child: Opacity(opacity: _fadeAnimation.value, child: child),
                );
              },
              child: SafeArea(
                bottom: !widget.showAtTop,
                top: widget.showAtTop,
                child: _buildBanner(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBanner() {
    final isOnline = _networkService.isOnline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOnline
              ? [Colors.green.shade700, Colors.green.shade600]
              : [Colors.red.shade800, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? Colors.green : Colors.red).withValues(
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // İkon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnline ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Mesaj
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'Bağlantı kuruldu' : 'İnternet bağlantısı yok',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? _networkService.getConnectionTypeText()
                      : 'Bazı özellikler kullanılamayabilir',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Animasyonlu gösterge
          if (!isOnline) _buildPulsingDot(),
        ],
      ),
    );
  }

  Widget _buildPulsingDot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: value),
          ),
        );
      },
      onEnd: () {
        // Animasyonu tekrarla
        if (mounted) {
          setState(() {});
        }
      },
    );
  }
}

/// Network durumuna göre koşullu widget gösterimi için builder
///
/// Kullanım:
/// ```dart
/// NetworkAwareBuilder(
///   onlineBuilder: (context) => OnlineContent(),
///   offlineBuilder: (context) => OfflineContent(),
/// )
/// ```
class NetworkAwareBuilder extends StatelessWidget {
  /// Online durumda gösterilecek widget builder
  final WidgetBuilder onlineBuilder;

  /// Offline durumda gösterilecek widget builder
  final WidgetBuilder offlineBuilder;

  /// Durum bilinmiyorken gösterilecek widget (opsiyonel)
  final WidgetBuilder? unknownBuilder;

  const NetworkAwareBuilder({
    super.key,
    required this.onlineBuilder,
    required this.offlineBuilder,
    this.unknownBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NetworkService(),
      builder: (context, child) {
        final status = NetworkService().status;

        switch (status) {
          case NetworkStatus.online:
            return onlineBuilder(context);
          case NetworkStatus.offline:
            return offlineBuilder(context);
          case NetworkStatus.unknown:
            return unknownBuilder?.call(context) ?? onlineBuilder(context);
        }
      },
    );
  }
}

/// Network durumunu gösteren kompakt indikatör widget'ı
///
/// AppBar veya herhangi bir yerde kullanılabilir
class NetworkIndicator extends StatelessWidget {
  /// İndikatör boyutu
  final double size;

  /// Online rengi
  final Color onlineColor;

  /// Offline rengi
  final Color offlineColor;

  const NetworkIndicator({
    super.key,
    this.size = 10,
    this.onlineColor = Colors.green,
    this.offlineColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NetworkService(),
      builder: (context, child) {
        final isOnline = NetworkService().isOnline;

        return Tooltip(
          message: isOnline
              ? 'Çevrimiçi - ${NetworkService().getConnectionTypeText()}'
              : 'Çevrimdışı',
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? onlineColor : offlineColor,
              boxShadow: [
                BoxShadow(
                  color: (isOnline ? onlineColor : offlineColor).withValues(
                    alpha: 0.4,
                  ),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
