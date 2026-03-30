import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';


class OfflineSensor extends StatefulWidget {
  final Widget child;

  const OfflineSensor({super.key, required this.child});

  @override
  State<OfflineSensor> createState() => _OfflineSensorState();
}

class _OfflineSensorState extends State<OfflineSensor> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;
  bool _firstCheckDone = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    _updateConnectionStatus(results);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isOffline = results.every((result) => result == ConnectivityResult.none);
    
    if (_firstCheckDone && _isOffline != isOffline) {
      if (mounted) setState(() => _isOffline = isOffline);
    } else if (!_firstCheckDone) {
      _firstCheckDone = true;
      if (isOffline) {
        if (mounted) setState(() => _isOffline = true);
      }
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  color: Colors.redAccent.withValues(alpha: 0.9),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_off, color: Colors.white, size: 14),
                      SizedBox(width: 8),
                      Text(
                        "Çevrimdışı (Offline) Mod - Değişiklikler kaydediliyor",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
