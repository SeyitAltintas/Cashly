import 'package:flutter/material.dart';

/// Lazy loading destekli ListView widget'ı
/// Büyük listeler için otomatik pagination sağlar.
class LazyLoadListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double loadMoreThreshold;

  const LazyLoadListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onLoadMore,
    this.hasMore = false,
    this.loadingWidget,
    this.emptyWidget,
    this.padding,
    this.controller,
    this.physics,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<LazyLoadListView<T>> createState() => _LazyLoadListViewState<T>();
}

class _LazyLoadListViewState<T> extends State<LazyLoadListView<T>> {
  late ScrollController _scrollController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_isLoading || !widget.hasMore || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final threshold = maxScroll - widget.loadMoreThreshold;

    if (currentScroll >= threshold) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await widget.onLoadMore?.call();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && !_isLoading) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      physics: widget.physics,
      itemCount: widget.items.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Son öğe ve daha fazla yüklenecekse loading göster
        if (index == widget.items.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: widget.loadingWidget ?? const CircularProgressIndicator(),
            ),
          );
        }

        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}

/// Pagination controller - sayfa bazlı veri yönetimi
class PaginationController<T> extends ChangeNotifier {
  final int pageSize;
  final Future<List<T>> Function(int page, int pageSize) fetchPage;

  List<T> _items = [];
  int _currentPage = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  List<T> get items => _items;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;

  PaginationController({this.pageSize = 20, required this.fetchPage});

  /// İlk sayfayı yükle (yenile)
  Future<void> refresh() async {
    _items = [];
    _currentPage = 0;
    _hasMore = true;
    _isLoading = false;
    notifyListeners();
    await loadMore();
  }

  /// Sonraki sayfayı yükle
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newItems = await fetchPage(_currentPage, pageSize);

      if (newItems.isEmpty || newItems.length < pageSize) {
        _hasMore = false;
      }

      _items.addAll(newItems);
      _currentPage++;
    } catch (e) {
      debugPrint('PaginationController loadMore hatası: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Belirli bir öğeyi güncelle
  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
      notifyListeners();
    }
  }

  /// Belirli bir öğeyi kaldır
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  /// Başa öğe ekle
  void insertAtStart(T item) {
    _items.insert(0, item);
    notifyListeners();
  }
}
