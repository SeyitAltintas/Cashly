import 'package:flutter/material.dart';

/// Lazy Loading için ortak mixin
/// ListView'lerde scroll sonunda daha fazla öğe yüklemek için kullanılır
mixin LazyLoadingMixin<T extends StatefulWidget> on State<T> {
  /// Sayfa başına gösterilecek öğe sayısı
  int get itemsPerPage => 20;

  /// Şu an gösterilen öğe sayısı
  int _displayedItemCount = 20;
  int get displayedItemCount => _displayedItemCount;

  /// Daha fazla veri yüklenebilir mi?
  bool _hasMoreItems = true;
  bool get hasMoreItems => _hasMoreItems;

  /// Yükleniyor mu?
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  /// Scroll controller
  late ScrollController lazyScrollController;

  /// Lazy loading'i başlat
  void initLazyLoading() {
    lazyScrollController = ScrollController();
    lazyScrollController.addListener(_onScroll);
    _displayedItemCount = itemsPerPage;
    _hasMoreItems = true;
    _isLoadingMore = false;
  }

  /// Lazy loading'i temizle
  void disposeLazyLoading() {
    lazyScrollController.removeListener(_onScroll);
    lazyScrollController.dispose();
  }

  /// Görüntülenen öğe sayısını sıfırla (filtre değiştiğinde çağrılır)
  void resetLazyLoading(int totalItemCount) {
    _displayedItemCount = itemsPerPage;
    _hasMoreItems = totalItemCount > itemsPerPage;
    _isLoadingMore = false;
  }

  /// Listeyi al ve sayfalama uygula
  List<E> applyPagination<E>(List<E> items) {
    _hasMoreItems = items.length > _displayedItemCount;
    if (items.length <= _displayedItemCount) {
      return items;
    }
    return items.take(_displayedItemCount).toList();
  }

  /// Scroll dinleyicisi
  void _onScroll() {
    if (_isLoadingMore || !_hasMoreItems) return;

    // Scroll sonuna yaklaşıldığında (100 piksel kala)
    if (lazyScrollController.position.pixels >=
        lazyScrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  /// Daha fazla öğe yükle
  void _loadMore() {
    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Küçük bir gecikme ile daha fazla yükle (UX için)
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _displayedItemCount += itemsPerPage;
          _isLoadingMore = false;
        });
      }
    });
  }

  /// Loading indicator widget'ı
  Widget buildLoadingIndicator() {
    if (!_isLoadingMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
