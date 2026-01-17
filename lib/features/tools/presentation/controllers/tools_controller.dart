import 'package:flutter/foundation.dart';

/// Tools Controller
/// Araçlar sayfası için ChangeNotifier tabanlı state yönetimi sağlar.
/// Navigasyon durumu ve haptic feedback ayarlarını yönetir.
class ToolsController extends ChangeNotifier {
  // ===== STATE =====

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Aktif bölüm takibi (gelecekte expanded section vb. için)
  String? _activeSection;
  String? get activeSection => _activeSection;

  // ===== METODLAR =====

  /// Loading durumunu güncelle
  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      notifyListeners();
    }
  }

  /// Aktif bölümü ayarla
  void setActiveSection(String? section) {
    if (_activeSection != section) {
      _activeSection = section;
      notifyListeners();
    }
  }

  /// State'i yenile
  void refresh() {
    notifyListeners();
  }
}
